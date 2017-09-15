#!/usr/bin/env bash

#Default values
DIRECTORY="reddit_wallpapers"
RESOLUTION="1920x1080"
SUBREDDIT="spaceporn"
JFILE="reddit_data.json"
DOMAINLIST="i.redd.it i.imgur.com"

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
        --file|-f)
            JFILE=$2;
            shift 2
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
    echo "-f | --file specifies a file to store JSON data."
    echo "-d | --directory specifies a directory to store the wallpapers."
    echo "-s | --subreddit specifies which subreddit to search."
    echo "-p | --persist makes the wallpaper changes persist after rebooting."
    exit 1
fi

#Changing User-Agent to bypass reddit's problem with curl's user-agent.  
curl -A "Mozilla/5.0 (X11; Linux x86_64; rv:55.0) Gecko/20100101 Firefox/55.0" -o ${JFILE} "https://www.reddit.com/r/${SUBREDDIT}/.json"

#Iterating over every post and download only the images that match the specified domain.
END=`jq '.data.children|length' ${JFILE}`
for ((CHILD=0; CHILD<$END; CHILD++))
do
    DATA=`jq ".data.children[$CHILD]" ${JFILE}`
    DOMAIN=`echo ${DATA} | jq -r '.data.domain'`
    for DOM in ${DOMAINLIST}
    do
        if [[ "$DOM" == "$DOMAIN" ]];
        then
            URL=`echo ${DATA} | jq -r '.data.url'`
            wget -nc -P ${DIRECTORY} ${URL}
        fi
    done
done

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
    DPATH=`realpath ${DIRECTORY} | rev | cut -d'/' -f2- | rev`    #Get the absolute path of $DIRECTORY and strip the $DIRECTORY from it
    OWNER=`ls -la ${DPATH}| sed -n 2p | awk '{print $3}'`         #Get the owner of $DIRECTORY's parent directory
    `chown -R ${OWNER} ${DPATH}`
    printf "#!/bin/sh\nfeh --bg-scale --randomize --no-fehbg ${DPATH}/${DIRECTORY}/*" > "/home/${OWNER}/.fehbg"
fi
