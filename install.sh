#!/bin/bash

if [ ! "E`lsb_release -i --short`" = "EUbuntu" ]
then
    echo "This program only support Ubuntu. "
    exit 255
fi

if [ `id -u` -eq 0 ]
then
    IS_SUDO=1
    WORKING_DIR="/opt/swift"
    INSTALL_DIR="/usr/bin"
    apt-get install wget -q -y
else
    IS_SUDO=0
    WORKING_DIR="$HOME/.swiftenv"
    INSTALL_DIR="/usr/local/bin"
    sudo apt-get install wget -q -y
fi

SWIFTENV_VERSION=`$INSTALL_DIR/swiftenv version`

if [ $? -eq 0 ]
then
    SUCCESS_MESSAGE="Successfully upgraded swiftenv from $SWIFTENV_VERSION to $LATEST_VERSION. "
else
    SUCCESS_MESSAGE="Successfully installed swiftenv $SWIFTENV_VERSION at $INSTALL_DIR. "
fi
LATEST_VERSION=`wget -q -O- "https://raw.githubusercontent.com/stevapple/swiftenv/master/VERSION"`
if [ ! $? -eq 0 ]
then
    echo "Error fetching the latest version. "
    exit 1
elif [ E$SWIFTENV_VERSION = E$LATEST_VERSION ]
then
    echo "Already installed the latest version $SWIFTENV_VERSION at $INSTALL_DIR. "
    exit
fi
wget -O "$INSTALL_DIR/swiftenv" "https://raw.githubusercontent.com/stevapple/swiftenv/$LATEST_VERSION/swiftenv.sh"
chmod +x "$INSTALL_DIR/swiftenv"
echo $SUCCESS_MESSAGE