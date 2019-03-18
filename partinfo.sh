#/bin/bash -x

# paramter check
if [ $# -lt 2 ] ; then 
     exit 0;
fi

case "$1" in
    boot)
        # accept
        ;;
    recovery)
        # accept
        ;;
    system)
        # accept
        ;;
    vendor)
        # accept
        ;;
    userdata)
        # accept
        ;;
    cache)
        # accept
        ;;
    dtb)
        # accept
        ;;
    *)
        # not accept
        exit 0;
        ;;
esac

case "$2" in
    size)
        # accept
        ;;
    *)
        # not accept
        exit 0;
        ;;
esac


if [ -e ${BSP_TOP_DIR}/output/images/partition_info.inc ] ; then
	source ${BSP_TOP_DIR}/output/images/partition_info.inc
	for part_info in "${part[@]}"; do
		# part = (name mount_point filesystem file size bErase)
		data=(${part_info[@]})
		size=${data[4]}
        # echo "name : ${data[0]} size : ${data[4]}"

		# return size
        if [ $1 == ${data[0]} ] ; then
            case "$2" in
                size)
                    echo ${data[4]};
                    exit 1;
                    ;;
                *)
                    ;;
            esac
        fi
	done
else
    exit 0;
fi
