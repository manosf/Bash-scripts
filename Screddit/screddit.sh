#!/usr/bin/env bash

#Default values
DIRECTORY="reddit_wallpapers"
RESOLUTION="1920x1080"
SUBREDDIT="spaceporn"


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
        --directory|-d)
            DIRECTORY=$2;
            shift 2
            ;;
        --subreddit|-s)
            SUBREDDIT=$2;
            shift 2
            ;;
        --resolution|-r)
            RESOLUTION=$2;
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
    echo "-d | --directory specifies a directory to store the wallpapers."
    echo "-s | --subreddit specifies which subreddit to search."
    echo "-p | --persist makes the wallpaper changes persist after rebooting."
    exit 1
fi

wget -O - "https://www.reddit.com/r/${SUBREDDIT}/top/?sort=top&t=week" | grep -oE 'https://i.(imgur.com|redd.it)/[a-zA-Z0-9]+.jpg' | xargs wget -r -l 5 -nc -P ${DIRECTORY}; 

printf "Wallpapers downloaded and saved in ${DIRECTORY}.\n"
printf "Select the ones you want now?[y/N]: "
read RESPONSE
case $RESPONSE in
        [Yy] | [Yy][Ee][Ss])
        2>/dev/null xdg-open `realpath ${DIRECTORY}` &
    ;;
esac


if [ "$PERSIST" == "1" ];
then
    DPATH=`realpath ${DIRECTORY}`
    OWNER=`ls -l ${DPATH} | awk '{print $3}'`
    echo "feh --bg-max --randomize --no-fehbg ${DIRECTORY}/i.imgur.com/*" >> "/home/${OWNER}/.fehbg"
fi
