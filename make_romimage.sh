#!/bin/bash
export WORK=`pwd`
export ROM_DIR=`echo ${BSP_TOP_DIR}/output/images`

gziped() {
	if [ -e ${ROM_DIR}/${1}_${2}${3}${4} ] ; then
		mv ${ROM_DIR}/${1}_${2}${3}${4} ${ROM_DIR}/${1}_${5}
		gzip -f ${ROM_DIR}/${1}_${5}
	fi
}

export -f gziped

extract_image_and_split() {
	echo convert sparse image to normal image.
	simg2img ${OUT}/${1} ${ROM_DIR}/${1}_no_spase
	echo Split 256M byte : ${1}.
	#split 256M byte.
	split -b 256M -a 3 ${ROM_DIR}/${1}_no_spase ${ROM_DIR}/${1}_
	array2=( a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z)
	count=0

	(for char1 in ${array2[@]}; do
		for char2 in ${array2[@]}; do
			for char3 in ${array2[@]}; do
				if [ ! -e ${ROM_DIR}/${1}_${char1}${char2}${char3} ] ; then
					exit 1;
				fi
				echo ${1} ${char1} ${char2} ${char3} ${count}
				count=`expr ${count} + 1`
			done
		done
	done) | xargs -n 5 -P 4 -I "%1 %2 %3 %4 %5" bash -c "gziped %1 %2 %3 %4 %5"
	rm -f ${ROM_DIR}/${1}_no_spase
}

# ------------ main -----------------
if [ -z $BSP_TOP_DIR ]; then
	echo "please set a \$BSP_TOP_DIR"
	exit;
fi

if [ ! -d ${ROM_DIR} ]; then
	echo "please build BSP first : ${ROM_DIR}"
	exit;
fi

if [ ! -d ${WORK}/out ]; then
	echo "please build Android first : ${WORK}/out"
	exit;
fi

echo "-----------------------------------"
echo "BSP_TOP_DIR : $BSP_TOP_DIR"
echo "ROM_DIR     : $ROM_DIR"
echo "OUT_DIR     : ${WORK}/out"
echo "-----------------------------------"

export -f extract_image_and_split
(for imgs in system.img ; do echo $imgs; done) | xargs -n 1 -P 3 -I % bash -c "extract_image_and_split %"

cp -f ${OUT}/vendor.img ${ROM_DIR}
cp -f ${OUT}/cache.img ${ROM_DIR}
cp -f ${OUT}/userdata.img ${ROM_DIR}

cp -f ${OUT}/boot.img ${ROM_DIR}
cp -f ${OUT}/recovery.img ${ROM_DIR}
if [ -e ${OUT}/vbmeta.img ] ; then cp -f ${OUT}/vbmeta.img ${ROM_DIR} ; fi
if [ -e ${OUT}/vbmeta.img ] ; then cp -f ${OUT}/dtb.img ${ROM_DIR} ; fi
echo done
