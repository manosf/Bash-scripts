#!/usr/bin/env bash

if [ "$EUID" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 
fi

for args in $*
do
    case $args in
        --help|-h)
            HELP="1";
            ;;
        --filename|-f)
            FILENAME=$2;
            shift 2
            ;;
        --subreddit|-s)
            SUBREDDIT=$2;
            shift 2
            ;;
        --persist|-p)
            PERSIST="1";
            shift
            ;;
    esac
done

if [ "$HELP" == "1" ];
then
    printf "Options and arguments:\n"
    echo "-f | --filename specifies a name for the wallpaper."
    echo "-s | --subreddit specifies which subreddit to search."
    echo "-p | --persist makes the wallpaper changes persist after rebooting."
    exit 1
fi

wget -nc -O - "https://www.reddit.com/r/${SUBREDDIT}/top/?sort=top&t=week" | grep -oE 'https://i.imgur.com/[a-zA-Z0-9]+.jpg' | shuf -n 1 | xargs wget -O ${FILENAME}; 
feh --bg-scale ${FILENAME};

if [ "$PERSIST" == "1" ];
then
    FPATH=`realpath screddit.sh`
    OWNER=`ls -l ${FPATH} | awk '{print $3}'`
    echo "~/.fehbg &" >> "/home/${OWNER}/.xinitrc"
fi


