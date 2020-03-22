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

INSTALL_DIR="/usr/bin"
SWIFTENV_VERSION=`$INSTALL_DIR/swiftenv version`

if [ $? -eq 0 ]
then
    SUCCESS_MESSAGE="Successfully upgraded swiftenv from $SWIFTENV_VERSION to $LATEST_VERSION. "
else
    SUCCESS_MESSAGE="Successfully installed swiftenv $LATEST_VERSION at $INSTALL_DIR. "
fi

LATEST_VERSION=`wget -q -O- "https://raw.githubusercontent.com/stevapple/swiftenv/master/VERSION"`
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

if [ E$SWIFTENV_VERSION = E$LATEST_VERSION ]
then
    echo "Already installed the latest version $SWIFTENV_VERSION at $INSTALL_DIR. "
    exit
fi

$SUDO_FLAG wget -O "$INSTALL_DIR/swiftenv" "https://raw.githubusercontent.com/stevapple/swiftenv/v$LATEST_VERSION/swiftenv.sh"
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
$SUDO_FLAG chmod +x "$INSTALL_DIR/swiftenv"
echo $SUCCESS_MESSAGE