#!/bin/bash

if [ ! "E`lsb_release -i --short`" = "EUbuntu" ]
then
    echo "This program only support Ubuntu. "
    exit 255
fi

if [ ! `id -u` -eq 0 ]
then
    SUDO_FLAG="sudo"
fi

$SUDO_FLAG apt-get install wget -q -y

LATEST_VERSION=`wget -q -O- "https://raw.githubusercontent.com/stevapple/swiftbox/master/VERSION"`
WGET_RESULT=$?
if [ $WGET_RESULT -ge 4 ]
then
    echo "Error: Please check your Internet connection and proxy settings. "
    exit $WGET_RESULT
elif [ $WGET_RESULT -ge 1 ]
then
    echo "Error: Please check your wget config. "
    exit $WGET_RESULT
fi

INSTALL_DIR="/usr/bin"
SWIFTBOX_VERSION=`$INSTALL_DIR/swiftbox version`
if [ $? -eq 0 ]
then
    SUCCESS_MESSAGE="Successfully upgraded swiftbox from $SWIFTBOX_VERSION to $LATEST_VERSION. "
else
    SUCCESS_MESSAGE="Successfully installed swiftbox $LATEST_VERSION at $INSTALL_DIR. "
fi

if [ E$SWIFTBOX_VERSION = E$LATEST_VERSION ]
then
    echo "Already installed the latest version $SWIFTBOX_VERSION at $INSTALL_DIR. "
    exit
fi

$SUDO_FLAG wget -O "$INSTALL_DIR/swiftbox" "https://raw.githubusercontent.com/stevapple/swiftbox/v$LATEST_VERSION/swiftbox.sh"
WGET_RESULT=$?
if [ $WGET_RESULT -eq 8 ]
then
    echo "Error: It seems the release isn't created yet. "
    exit $WGET_RESULT
elif [ $WGET_RESULT -ge 4 ]
then
    echo "Error: Please check your Internet connection and proxy settings. "
    exit $WGET_RESULT
elif [ $WGET_RESULT -ge 1 ]
then
    echo "Error: Please check your wget config. "
    exit $WGET_RESULT
fi
$SUDO_FLAG chmod +x "$INSTALL_DIR/swiftbox"
hash -r
echo $SUCCESS_MESSAGE