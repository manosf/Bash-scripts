#!/bin/bash

if [ "$EUID" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 
fi

for args in $*
do
    case $args in
        --filename|-f)
            FILENAME=$2;
            shift 2
            ;;
        --subreddit|-s)
            SUBREDDIT=$2;
            shift 2
            ;;
    esac
done


wget -nc -O - "https://www.reddit.com/r/${SUBREDDIT}/top/?sort=top&t=week" | grep -oE 'https://i.imgur.com/[A-Za-z]+.jpg' | shuf -n 1 | xargs wget -O ${FILENAME}; 
feh --bg-scale ${FILENAME};
