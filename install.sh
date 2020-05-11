#!/bin/bash

if [ ! `id -u` -eq 0 ]
then
    SUDO_FLAG="sudo"
fi

if [ "E`lsb_release -i --short`" = "EUbuntu" ]
then
    $SUDO_FLAG apt-get install curl jq -q=2
elif [[ `cat /etc/redhat-release` =~ "CentOS" || `cat /etc/redhat-release` =~ "Red Hat Enterprise Linux" ]]
then
    $SUDO_FLAG yum install curl jq -q -y
else
    echo "This program only supports Ubuntu and CentOS (RHEL). "
    exit 255
fi

LATEST_VERSION=`curl -fsSL - https://api.github.com/repos/stevapple/swiftbox/releases/latest | jq .tag_name | sed "s/v//" | sed "s/\"//g"`
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

$SUDO_FLAG curl -o "$INSTALL_DIR/swiftbox" "https://cdn.jsdelivr.net/gh/stevapple/swiftbox@$LATEST_VERSION/swiftbox.sh"
$SUDO_FLAG chmod +x "$INSTALL_DIR/swiftbox"
hash -r
echo $SUCCESS_MESSAGE