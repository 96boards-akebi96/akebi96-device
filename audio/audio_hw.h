/* SPDX-License-Identifier: Apache-2.0 */
/* Copyright (C) 2015 Socioenxt Inc. */

#ifndef __AUDIO_HW_H__
#define __AUDIO_HW_H__


#if (__ANDROID_API__ <= 19)
/**
 * return the frame size (number of bytes per sample) of an output stream.
 */
static inline size_t audio_stream_out_frame_size(const struct audio_stream_out *s)
{
    return audio_stream_frame_size(&s->common);
}

/**
 * return the frame size (number of bytes per sample) of an input stream.
 */
static inline size_t audio_stream_in_frame_size(const struct audio_stream_in *s)
{
    return audio_stream_frame_size(&s->common);
}

static inline uint32_t audio_channel_count_from_in_mask(audio_channel_mask_t channel)
{
	
	return 1;
}

static inline uint32_t audio_channel_count_from_out_mask(audio_channel_mask_t channel)
{
	return 2;
}
#endif


#endif /* __AUDIO_HW_H__ */
