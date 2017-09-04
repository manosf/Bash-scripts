#!/bin/bash

for args in $*
do
    case $args in
        --file|-f)
            FILE=$2
            shift
            ;;
    esac
done

#Make sure only root can run the script to have permission for every file
if [ "$EUID" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 
fi

echo "The process has started. Results will be exported to ${FILE}"
sudo du --block-size=1M --max-depth 1 -h /home/ | sort -rn >> ${FILE}

