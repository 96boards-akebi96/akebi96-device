// SPDX-License-Identifier: Apache-2.0
/*
 * Copyright (C) 2012 The Android Open Source Project
 * Copyright (C) 2015 Socionext Inc.
 *
 * based on hardware/libhardware/modules/audio/audio_hw.c
 */

#define LOG_TAG "audio_hw_primary"
/*#define LOG_NDEBUG 0*/

#include <errno.h>
#include <pthread.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/time.h>
#include <unistd.h>

#include <log/log.h>
#include <cutils/properties.h>
#include <cutils/str_parms.h>

#include <hardware/audio.h>
#include <hardware/hardware.h>

#include <system/audio.h>

#include <tinyalsa/asoundlib.h>

#include <audio_utils/resampler.h>
#include <audio_route/audio_route.h>

#include <audio_hw.h>

/* 4 is number of byte of PCM_FORMAT_S32_LE */
#define OUT_MAX_PREOD_SAMPLE (OUT_PERIOD_SIZE * OUT_LONG_PERIOD_COUNT) / (NUM_OF_CHANNELS * 4)

/* minimum sleep time in out_write() when write threshold is not reached */
#define MIN_WRITE_SLEEP_US 1000
#define MAX_WRITE_SLEEP_US ((OUT_MAX_PREOD_SAMPLE * 1000000L) / OUT_SAMPLING_RATE)

#define UNUSED(a) (a)

enum {
    OUT_BUFFER_TYPE_UNKNOWN,
    OUT_BUFFER_TYPE_SHORT,
    OUT_BUFFER_TYPE_LONG,
};

struct pcm_config pcm_config_out;

struct audio_device {
    struct audio_hw_device hw_device;

    pthread_mutex_t lock; /* see note below on mutex acquisition order */
    unsigned int out_device;
    unsigned int in_device;
    bool standby;
    bool mic_mute;
    struct audio_route *ar;
    int orientation;
    bool screen_off;

    struct stream_out *active_out;
};

struct stream_out {
    struct audio_stream_out stream;

    pthread_mutex_t lock; /* see note below on mutex acquisition order */
    struct pcm *pcm;
    struct pcm_config *pcm_config;
    bool standby;
    uint64_t written; /* total frames written, not cleared when entering standby */

    struct resampler_itfe *resampler;
    int16_t *buffer;
    size_t buffer_frames;

    int write_threshold;
    int cur_write_threshold;
    int buffer_type;

    struct audio_device *dev;
};

enum {
    ORIENTATION_LANDSCAPE,
    ORIENTATION_PORTRAIT,
    ORIENTATION_SQUARE,
    ORIENTATION_UNDEFINED,
};

static uint32_t out_get_sample_rate(const struct audio_stream *stream);
static size_t out_get_buffer_size(const struct audio_stream *stream);
static audio_format_t out_get_format(const struct audio_stream *stream);

/*
 * NOTE: when multiple mutexes have to be acquired, always take the
 * audio_device mutex first, followed by the stream_in and/or
 * stream_out mutexes.
 */

/* Helper functions */

static void select_devices(struct audio_device *adev)
{
    int headphone_on;
    int speaker_on;
    int docked;
    int main_mic_on;

    headphone_on = adev->out_device & (AUDIO_DEVICE_OUT_WIRED_HEADSET |
                                    AUDIO_DEVICE_OUT_WIRED_HEADPHONE);
    speaker_on = adev->out_device & AUDIO_DEVICE_OUT_SPEAKER;
    docked = adev->out_device & AUDIO_DEVICE_OUT_ANLG_DOCK_HEADSET;
    main_mic_on = adev->in_device & AUDIO_DEVICE_IN_BUILTIN_MIC;

    audio_route_reset(adev->ar);

    if (speaker_on)
        audio_route_apply_path(adev->ar, "speaker");
    if (headphone_on)
        audio_route_apply_path(adev->ar, "headphone");
    if (docked)
        audio_route_apply_path(adev->ar, "dock");
    if (main_mic_on) {
        if (adev->orientation == ORIENTATION_LANDSCAPE)
            audio_route_apply_path(adev->ar, "main-mic-left");
        else
            audio_route_apply_path(adev->ar, "main-mic-top");
    }

    audio_route_update_mixer(adev->ar);

    ALOGV("hp=%c speaker=%c dock=%c main-mic=%c", headphone_on ? 'y' : 'n',
          speaker_on ? 'y' : 'n', docked ? 'y' : 'n', main_mic_on ? 'y' : 'n');
}

/* must be called with hw device and output stream mutexes locked */
static void do_out_standby(struct stream_out *out)
{
    struct audio_device *adev = out->dev;

    if (!out->standby) {
#ifndef ALWAYS_ALSA_OPEN
        pcm_close(out->pcm);
        out->pcm = NULL;
#endif
        adev->active_out = NULL;
        if (out->resampler) {
            release_resampler(out->resampler);
            out->resampler = NULL;
        }
        if (out->buffer) {
            free(out->buffer);
            out->buffer = NULL;
        }
        out->standby = true;
    }
}

/* must be called with hw device and output stream mutexes locked */
static int start_output_stream(struct stream_out *out)
{
    struct audio_device *adev = out->dev;
    unsigned int device = PCM_DEVICE;
    unsigned int card = PCM_CARD;
    int ret;

    /*
     * Due to the lack of sample rate converters in the SoC,
     * it greatly simplifies things to have only the main
     * (speaker/headphone) PCM or the BC SCO PCM open at
     * the same time.
     */
    if (adev->out_device & AUDIO_DEVICE_OUT_SPEAKER) {
        card = PCM_CARD;
        device = PCM_DEVICE;
        out->pcm_config = &pcm_config_out;
        out->buffer_type = OUT_BUFFER_TYPE_UNKNOWN;
    }

    if (out->pcm == NULL) {
        out->pcm = pcm_open(card, device, PCM_OUT | PCM_NORESTART | PCM_MONOTONIC, out->pcm_config);
    }

    if (out->pcm && !pcm_is_ready(out->pcm)) {
        ALOGE("pcm_open(out) failed: %s", pcm_get_error(out->pcm));
#ifndef ALWAYS_ALSA_OPEN
        pcm_close(out->pcm);
#endif /* ALWAYS_ALSA_OPEN */
        return -ENOMEM;
    }

    /*
     * If the stream rate differs from the PCM rate, we need to
     * create a resampler.
     */
    if (out_get_sample_rate(&out->stream.common) != out->pcm_config->rate) {
        ret = create_resampler(out_get_sample_rate(&out->stream.common),
                               out->pcm_config->rate,
                               out->pcm_config->channels,
                               RESAMPLER_QUALITY_DEFAULT,
                               NULL,
                               &out->resampler);
        out->buffer_frames = (pcm_config_out.period_size * out->pcm_config->rate) /
                out_get_sample_rate(&out->stream.common) + 1;

        out->buffer = malloc(pcm_frames_to_bytes(out->pcm, out->buffer_frames));
    }

    adev->active_out = out;

    return 0;
}

/* API functions */

static uint32_t out_get_sample_rate(const struct audio_stream *stream __unused)
{
    return pcm_config_out.rate;
}

static int out_set_sample_rate(struct audio_stream *stream __unused, uint32_t rate __unused)
{
    return -ENOSYS;
}

static size_t out_get_buffer_size(const struct audio_stream *stream)
{
    return pcm_config_out.period_size *
               audio_stream_out_frame_size((const struct audio_stream_out *)stream);
}

static uint32_t out_get_channels(const struct audio_stream *stream __unused)
{
    return AUDIO_CHANNEL_OUT_STEREO;
}

static audio_format_t out_get_format(const struct audio_stream *stream __unused)
{
    return AUDIO_FORMAT_PCM_32_BIT;
}

static int out_set_format(struct audio_stream *stream __unused, audio_format_t format __unused)
{
    return -ENOSYS;
}

static int out_standby(struct audio_stream *stream)
{
    struct stream_out *out = (struct stream_out *)stream;

    pthread_mutex_lock(&out->dev->lock);
    pthread_mutex_lock(&out->lock);
    do_out_standby(out);
    pthread_mutex_unlock(&out->lock);
    pthread_mutex_unlock(&out->dev->lock);

    return 0;
}

static int out_dump(const struct audio_stream *stream __unused, int fd __unused)
{
    return 0;
}

static int out_set_parameters(struct audio_stream *stream, const char *kvpairs)
{
    struct stream_out *out = (struct stream_out *)stream;
    struct audio_device *adev = out->dev;
    struct str_parms *parms;
    char value[32];
    int ret;
    unsigned int val;

    parms = str_parms_create_str(kvpairs);

    ret = str_parms_get_str(parms, AUDIO_PARAMETER_STREAM_ROUTING,
                            value, sizeof(value));
    pthread_mutex_lock(&adev->lock);
    if (ret >= 0) {
        val = atoi(value);
        if ((adev->out_device != val) && (val != 0)) {
            /*
             * If route was chagend, we need to put audio into standby
             * because SCO uses a different PCM.
             */
            pthread_mutex_lock(&out->lock);
            do_out_standby(out);
            pthread_mutex_unlock(&out->lock);

            adev->out_device = val;
            select_devices(adev);
        }
    }
    pthread_mutex_unlock(&adev->lock);

    str_parms_destroy(parms);
    return ret;
}

static char * out_get_parameters(const struct audio_stream *stream __unused, const char *keys __unused)
{
    return strdup("");
}

static uint32_t out_get_latency(const struct audio_stream_out *stream)
{
    struct stream_out *out = (struct stream_out *)stream;
    struct audio_device *adev = out->dev;
    size_t period_count;

    pthread_mutex_lock(&adev->lock);

    period_count = OUT_SHORT_PERIOD_COUNT;

    pthread_mutex_unlock(&adev->lock);

    return (pcm_config_out.period_size * period_count * 1000) / pcm_config_out.rate;
}

static int out_set_volume(struct audio_stream_out *stream __unused, float left __unused,
                          float right __unused)
{
    return -ENOSYS;
}

static ssize_t out_write(struct audio_stream_out *stream, const void* buffer,
                         size_t bytes)
{
    int ret = 0;
    struct stream_out *out = (struct stream_out *)stream;
    struct audio_device *adev = out->dev;
    size_t frame_size = audio_stream_out_frame_size(stream);
    int32_t *in_buffer = (int32_t *)buffer;
    size_t in_frames = bytes / frame_size;
    size_t out_frames;
    int buffer_type;
    int kernel_frames = 0;
    bool sco_on;

    /*
     * acquiring hw device mutex systematically is useful if a low
     * priority thread is waiting on the output stream mutex - e.g.
     * executing out_set_parameters() while holding the hw device
     * mutex
     */
    pthread_mutex_lock(&adev->lock);
    pthread_mutex_lock(&out->lock);
    if (out->standby) {
        ret = start_output_stream(out);
        if (ret != 0) {
            pthread_mutex_unlock(&adev->lock);
            goto exit;
        }
        out->standby = false;
    }
    buffer_type = OUT_BUFFER_TYPE_SHORT;
    sco_on = (adev->out_device & AUDIO_DEVICE_OUT_ALL_SCO);
    pthread_mutex_unlock(&adev->lock);

    /* detect changes in screen ON/OFF state and adapt buffer size
     * if needed. Do not change buffer size when routed to SCO device. */
    if (!sco_on && (buffer_type != out->buffer_type)) {
        size_t period_count;

        if (buffer_type == OUT_BUFFER_TYPE_LONG)
            period_count = OUT_LONG_PERIOD_COUNT;
        else
            period_count = OUT_SHORT_PERIOD_COUNT;

        out->write_threshold = out->pcm_config->period_size * period_count;
        /* reset current threshold if exiting standby */
        if (out->buffer_type == OUT_BUFFER_TYPE_UNKNOWN)
            out->cur_write_threshold = out->write_threshold;
        out->buffer_type = buffer_type;
    }

    /* Reduce number of channels, if necessary */
    if (audio_channel_count_from_out_mask(out_get_channels(&stream->common)) >
                 out->pcm_config->channels) {
        unsigned int i;

        /* Discard right channel */
        for (i = 1; i < in_frames; i++)
            in_buffer[i] = in_buffer[i * 2];

        /* The frame size is now half */
        frame_size /= 2;
    }

    /* Change sample rate, if necessary */
    if (out_get_sample_rate(&stream->common) != out->pcm_config->rate) {
        out_frames = out->buffer_frames;
        out->resampler->resample_from_input(out->resampler,
											(int16_t *)in_buffer, &in_frames,
                                            out->buffer, &out_frames);
		in_buffer = (int32_t *)out->buffer;
    } else {
        out_frames = in_frames;
    }

    if (!sco_on) {
        int total_sleep_time_us = 0;
        size_t period_size = out->pcm_config->period_size;

        /* do not allow more than out->cur_write_threshold frames in kernel
         * pcm driver buffer */
        do {
            struct timespec time_stamp;
            if (pcm_get_htimestamp(out->pcm,
                                   (unsigned int *)&kernel_frames,
                                   &time_stamp) < 0)
                break;
            kernel_frames = pcm_get_buffer_size(out->pcm) - kernel_frames;

            if (kernel_frames > out->cur_write_threshold) {
                int sleep_time_us =
                    (int)(((int64_t)((kernel_frames - out->cur_write_threshold) * 1000000L)
                            / (out->pcm_config->channels * 4) / out->pcm_config->rate));
                if (sleep_time_us < MIN_WRITE_SLEEP_US)
                    break;
                total_sleep_time_us += sleep_time_us;
                if (total_sleep_time_us > MAX_WRITE_SLEEP_US) {
                    ALOGV("out_write() limiting sleep time %d to %ld",
                          total_sleep_time_us, MAX_WRITE_SLEEP_US);
                }
                usleep(sleep_time_us);
            }

        } while ((kernel_frames > out->cur_write_threshold) &&
                (total_sleep_time_us <= MAX_WRITE_SLEEP_US));

        /* do not allow abrupt changes on buffer size. Increasing/decreasing
         * the threshold by steps of 1/4th of the buffer size keeps the write
         * time within a reasonable range during transitions.
         * Also reset current threshold just above current filling status when
         * kernel buffer is really depleted to allow for smooth catching up with
         * target threshold.
         */
        if (out->cur_write_threshold > out->write_threshold) {
            out->cur_write_threshold -= period_size / 4;
            if (out->cur_write_threshold < out->write_threshold) {
                out->cur_write_threshold = out->write_threshold;
            }
        } else if (out->cur_write_threshold < out->write_threshold) {
            out->cur_write_threshold += period_size / 4;
            if (out->cur_write_threshold > out->write_threshold) {
                out->cur_write_threshold = out->write_threshold;
            }
        } else if ((kernel_frames < out->write_threshold) &&
            ((out->write_threshold - kernel_frames) >
                (int)(period_size * OUT_SHORT_PERIOD_COUNT))) {
            out->cur_write_threshold = (kernel_frames / period_size + 1) * period_size;
            out->cur_write_threshold += period_size / 4;
        }
    }

    ret = pcm_write(out->pcm, in_buffer, out_frames * frame_size);
    if (ret == -EPIPE) {
        /* In case of underrun, don't sleep since we want to catch up asap */
        pthread_mutex_unlock(&out->lock);
        return ret;
    }
    if (ret == 0) {
        out->written += out_frames;
    }

exit:
    pthread_mutex_unlock(&out->lock);

    if (ret != 0) {
        usleep(bytes * 1000000 / audio_stream_out_frame_size((const struct audio_stream_out *)&stream->common) /
               out_get_sample_rate(&stream->common));
    }

    return bytes;
}

static int out_get_render_position(const struct audio_stream_out *stream __unused,
                                   uint32_t *dsp_frames __unused)
{
    return -EINVAL;
}

static int out_add_audio_effect(const struct audio_stream *stream __unused, effect_handle_t effect __unused)
{
    return 0;
}

static int out_remove_audio_effect(const struct audio_stream *stream __unused, effect_handle_t effect __unused)
{
    return 0;
}

static int out_get_next_write_timestamp(const struct audio_stream_out *stream __unused,
                                        int64_t *timestamp __unused)
{
    return -EINVAL;
}

static int out_get_presentation_position(const struct audio_stream_out *stream,
                                   uint64_t *frames, struct timespec *timestamp)
{
    struct stream_out *out = (struct stream_out *)stream;
    int ret = -1;

    pthread_mutex_lock(&out->lock);

    unsigned int avail;
    if (pcm_get_htimestamp(out->pcm, &avail, timestamp) == 0) {
        size_t kernel_buffer_size = out->pcm_config->period_size * out->pcm_config->period_count;
        // FIXME This calculation is incorrect if there is buffering after app processor
        int64_t signed_frames = out->written - kernel_buffer_size + avail;
        // It would be unusual for this value to be negative, but check just in case ...
        if (signed_frames >= 0) {
            *frames = signed_frames;
            ret = 0;
        }
    }

    pthread_mutex_unlock(&out->lock);

    return ret;
}

static int adev_open_output_stream(struct audio_hw_device *dev,
                                   audio_io_handle_t handle __unused,
                                   audio_devices_t devices __unused,
                                   audio_output_flags_t flags __unused,
                                   struct audio_config *config,
                                   struct audio_stream_out **stream_out,
                                   const char *address __unused)
{
    struct audio_device *adev = (struct audio_device *)dev;
    struct stream_out *out;


    out = (struct stream_out *)calloc(1, sizeof(struct stream_out));
    if (!out)
        return -ENOMEM;

    out->stream.common.get_sample_rate = out_get_sample_rate;
    out->stream.common.set_sample_rate = out_set_sample_rate;
    out->stream.common.get_buffer_size = out_get_buffer_size;
    out->stream.common.get_channels = out_get_channels;
    out->stream.common.get_format = out_get_format;
    out->stream.common.set_format = out_set_format;
    out->stream.common.standby = out_standby;
    out->stream.common.dump = out_dump;
    out->stream.common.set_parameters = out_set_parameters;
    out->stream.common.get_parameters = out_get_parameters;
    out->stream.common.add_audio_effect = out_add_audio_effect;
    out->stream.common.remove_audio_effect = out_remove_audio_effect;
    out->stream.get_latency = out_get_latency;
    out->stream.set_volume = out_set_volume;
    out->stream.write = out_write;
    out->stream.get_render_position = out_get_render_position;
    out->stream.get_next_write_timestamp = out_get_next_write_timestamp;
    out->stream.get_presentation_position = out_get_presentation_position;

    out->dev = adev;

    config->format = out_get_format(&out->stream.common);
    config->channel_mask = out_get_channels(&out->stream.common);
    config->sample_rate = out_get_sample_rate(&out->stream.common);

    out->standby = true;
    /* out->written = 0; by calloc() */

    *stream_out = &out->stream;
#ifdef ALWAYS_ALSA_OPEN
    {
        unsigned int device = PCM_DEVICE;
        unsigned int card = PCM_CARD;
        out->pcm_config = &pcm_config_out;
        out->pcm = pcm_open(card, device, PCM_OUT | PCM_NORESTART | PCM_MONOTONIC, out->pcm_config);
    }
#endif /* ALWAYS_ALSA_OPEN */

    return 0;
}

static void adev_close_output_stream(struct audio_hw_device *dev __unused,
                                     struct audio_stream_out *stream)
{
    out_standby(&stream->common);
    free(stream);
}

static int adev_set_parameters(struct audio_hw_device *dev, const char *kvpairs)
{
    struct audio_device *adev = (struct audio_device *)dev;
    struct str_parms *parms;
    char value[32];
    int ret;

    parms = str_parms_create_str(kvpairs);
    ret = str_parms_get_str(parms, "orientation", value, sizeof(value));
    if (ret >= 0) {
        int orientation;

        if (strcmp(value, "landscape") == 0)
            orientation = ORIENTATION_LANDSCAPE;
        else if (strcmp(value, "portrait") == 0)
            orientation = ORIENTATION_PORTRAIT;
        else if (strcmp(value, "square") == 0)
            orientation = ORIENTATION_SQUARE;
        else
            orientation = ORIENTATION_UNDEFINED;

        pthread_mutex_lock(&adev->lock);
        if (orientation != adev->orientation) {
            adev->orientation = orientation;
            /*
             * Orientation changes can occur with the input device
             * closed so we must call select_devices() here to set
             * up the mixer. This is because select_devices() will
             * not be called when the input device is opened if no
             * other input parameter is changed.
             */
            select_devices(adev);
        }
        pthread_mutex_unlock(&adev->lock);
    }

    ret = str_parms_get_str(parms, "screen_state", value, sizeof(value));
    if (ret >= 0) {
        if (strcmp(value, AUDIO_PARAMETER_VALUE_ON) == 0)
            adev->screen_off = false;
        else
            adev->screen_off = true;
    }

    str_parms_destroy(parms);
    return ret;
}

static char * adev_get_parameters(const struct audio_hw_device *dev __unused,
                                  const char *keys __unused)
{
    return strdup("");
}

static int adev_init_check(const struct audio_hw_device *dev __unused)
{
    return 0;
}

static int adev_set_voice_volume(struct audio_hw_device *dev __unused, float volume __unused)
{
    return -ENOSYS;
}

static int adev_set_master_volume(struct audio_hw_device *dev __unused, float volume __unused)
{
    return -ENOSYS;
}

static int adev_set_mode(struct audio_hw_device *dev __unused, audio_mode_t mode __unused)
{
    return 0;
}

static int adev_set_mic_mute(struct audio_hw_device *dev, bool state)
{
    struct audio_device *adev = (struct audio_device *)dev;

    adev->mic_mute = state;

    return 0;
}

static int adev_get_mic_mute(const struct audio_hw_device *dev, bool *state)
{
    struct audio_device *adev = (struct audio_device *)dev;

    *state = adev->mic_mute;

    return 0;
}

static size_t adev_get_input_buffer_size(const struct audio_hw_device *dev __unused,
                                         const struct audio_config *config __unused)
{
    return 0;
}

static int adev_open_input_stream(struct audio_hw_device *dev __unused,
                                  audio_io_handle_t handle __unused,
                                  audio_devices_t devices __unused,
                                  struct audio_config *config __unused,
                                  struct audio_stream_in **stream_in __unused,
                                  audio_input_flags_t flags __unused,
                                  const char *address __unused,
                                  audio_source_t source __unused)
{
    return 0;
}

static void adev_close_input_stream(struct audio_hw_device *dev __unused,
                                   struct audio_stream_in *stream __unused)
{
}

static int adev_dump(const audio_hw_device_t *device __unused, int fd __unused)
{
    return 0;
}

static int adev_close(hw_device_t *device)
{
    struct audio_device *adev = (struct audio_device *)device;

    audio_route_free(adev->ar);

    free(device);
    return 0;
}

static int adev_open(const hw_module_t* module, const char* name,
                     hw_device_t** device)
{
    struct audio_device *adev;

    if (strcmp(name, AUDIO_HARDWARE_INTERFACE) != 0)
        return -EINVAL;

    adev = calloc(1, sizeof(struct audio_device));
    if (!adev)
        return -ENOMEM;

    adev->hw_device.common.tag = HARDWARE_DEVICE_TAG;
    adev->hw_device.common.version = AUDIO_DEVICE_API_VERSION_2_0;
    adev->hw_device.common.module = (struct hw_module_t *) module;
    adev->hw_device.common.close = adev_close;

    adev->hw_device.init_check = adev_init_check;
    adev->hw_device.set_voice_volume = adev_set_voice_volume;
    adev->hw_device.set_master_volume = adev_set_master_volume;
    adev->hw_device.set_mode = adev_set_mode;
    adev->hw_device.set_mic_mute = adev_set_mic_mute;
    adev->hw_device.get_mic_mute = adev_get_mic_mute;
    adev->hw_device.set_parameters = adev_set_parameters;
    adev->hw_device.get_parameters = adev_get_parameters;
    adev->hw_device.get_input_buffer_size = adev_get_input_buffer_size;
    adev->hw_device.open_output_stream = adev_open_output_stream;
    adev->hw_device.close_output_stream = adev_close_output_stream;
    adev->hw_device.open_input_stream = adev_open_input_stream;
    adev->hw_device.close_input_stream = adev_close_input_stream;
    adev->hw_device.dump = adev_dump;

    adev->ar = audio_route_init(MIXER_CARD, "/vendor/etc/mixer_paths.xml");
    adev->orientation = ORIENTATION_UNDEFINED;
    adev->out_device = AUDIO_DEVICE_OUT_SPEAKER;
    adev->in_device = AUDIO_DEVICE_IN_BUILTIN_MIC & ~AUDIO_DEVICE_BIT_IN;

    *device = &adev->hw_device.common;

    memset(&pcm_config_out, 0 , sizeof(struct pcm_config));
    pcm_config_out.channels = NUM_OF_CHANNELS;
    pcm_config_out.rate = OUT_SAMPLING_RATE;
    pcm_config_out.period_size = OUT_PERIOD_SIZE;
    pcm_config_out.period_count = OUT_LONG_PERIOD_COUNT;
    pcm_config_out.format = PCM_FORMAT_S32_LE;
    pcm_config_out.start_threshold = OUT_PERIOD_SIZE * OUT_SHORT_PERIOD_COUNT;

    return 0;
}

static struct hw_module_methods_t hal_module_methods = {
    .open = adev_open,
};

struct audio_module HAL_MODULE_INFO_SYM = {
    .common = {
        .tag = HARDWARE_MODULE_TAG,
        .module_api_version = AUDIO_MODULE_API_VERSION_0_1,
        .hal_api_version = HARDWARE_HAL_API_VERSION,
        .id = AUDIO_HARDWARE_MODULE_ID,
        .name = "Uniphier ALSA audio HW HAL",
        .author = "The Android Open Source Project",
        .methods = &hal_module_methods,
    },
};
