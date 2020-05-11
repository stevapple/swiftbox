#!/bin/bash

if [ ! `id -u` -eq 0 ]
then
    SUDO_FLAG="sudo"
fi

if [ "E`lsb_release -i --short`" = "EUbuntu" ]
then
    $SUDO_FLAG apt-get install wget -q=2
elif [[ `cat /etc/redhat-release` =~ "CentOS" || `cat /etc/redhat-release` =~ "Red Hat Enterprise Linux" ]]
then
    $SUDO_FLAG yum install wget -q -y
else
    echo "This program only supports Ubuntu and CentOS (RHEL). "
    exit 255
fi

LATEST_VERSION=`wget -q -O- "https://cdn.jsdelivr.net/gh/stevapple/swiftbox/VERSION"`
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
elif [[ $SWIFTBOX_VERSION > $LATEST_VERSION ]]
    echo "Already installed the latest version $SWIFTBOX_VERSION at $INSTALL_DIR. "
    exit
fi

$SUDO_FLAG wget -O "$INSTALL_DIR/swiftbox" "https://cdn.jsdelivr.net/gh/stevapple/swiftbox@$LATEST_VERSION/swiftbox.sh"
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