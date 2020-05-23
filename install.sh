#!/bin/bash

if [ `id -u` != 0 ] && hash sudo 2> /dev/null
then
    SUDO_FLAG="sudo"
fi

if [ -f /etc/os-release ]
then
    ID=`cat /etc/os-release | grep '^ID=' | sed 's/ID=//g' | sed 's/"//g'`
    case $ID in
    ubuntu)
        if hash curl 2> /dev/null || ! hash realpath 2> /dev/null || ! hash jq 2> /dev/null
        then
            $SUDO_FLAG apt-get update -q=2
            $SUDO_FLAG apt-get install coreutils curl jq -q=2
        fi
    ;;
    rhel | centos | amzn)
        if ! hash curl 2> /dev/null || ! hash jq 2> /dev/null
        then
            $SUDO_FLAG yum install curl jq -q -y
        fi
    ;;
    *)
        UNSUPPORTED_SYSTEM=`cat /etc/os-release | grep '^PRETTY_NAME=' | sed 's/PRETTY_NAME=//g' | sed 's/"//g'`
    ;;
    esac
elif hash uname 2> /dev/null
then
    UNSUPPORTED_SYSTEM=`uname -v`
else
    UNSUPPORTED_SYSTEM="This strange OS"
fi

if [ "$UNSUPPORTED_SYSTEM" ]
then 
    echo "This program only supports Ubuntu, CentOS(RHEL) and Amazon Linux."
    echo "$UNSUPPORTED_SYSTEM is unsupported."
    exit 255
fi

LATEST_VERSION=`curl -fsSL https://api.github.com/repos/stevapple/swiftbox/releases/latest | jq .tag_name | sed "s/v//" | sed "s/\"//g"`
INSTALL_DIR=`realpath /usr/bin`

if [ ! "$LATEST_VERSION" ]
then
    echo "Please check your Internet connection, especially GitHub availability."
    exit 4
fi

if [ -d $INSTALL_DIR/swiftbox ]
then
    echo "Unexpected directory in $INSTALL_DIR/swiftbox"
    exit 254
elif [ -f $INSTALL_DIR/swiftbox ]
then
    if [ ! -x $INSTALL_DIR/swiftbox ]
    then
        $SUDO_FLAG chmod +x $INSTALL_DIR/swiftbox
    fi
    SWIFTBOX_VERSION=`$INSTALL_DIR/swiftbox version`
    if [ "E$SWIFTBOX_VERSION" = "E$LATEST_VERSION" ]
    then
        echo "Already installed the latest version $SWIFTBOX_VERSION at $INSTALL_DIR"
        exit
    fi
    if [ "$SWIFTBOX_VERSION" ]
    then
        SUCCESS_MESSAGE="Successfully upgraded swiftbox from $SWIFTBOX_VERSION to $LATEST_VERSION"
    else
        SUCCESS_MESSAGE="Successfully installed swiftbox $LATEST_VERSION at $INSTALL_DIR"
    fi
else
    SUCCESS_MESSAGE="Successfully installed swiftbox $LATEST_VERSION at $INSTALL_DIR"
fi

URL="https://cdn.jsdelivr.net/gh/stevapple/swiftbox@$LATEST_VERSION/swiftbox.sh"
echo "Downloading swiftbox $LATEST_VERSION from $URL"
$SUDO_FLAG curl -o $INSTALL_DIR/swiftbox $URL -#
$SUDO_FLAG chmod +x $INSTALL_DIR/swiftbox
hash -r
echo $SUCCESS_MESSAGE