#!/bin/bash

if [ ! `id -u` -eq 0 ]
then
    SUDO_FLAG="sudo"
fi

if [ -f "/etc/redhat-release" ]
then
    REDHAT_RELEASE=`cat /etc/redhat-release`
    if [[ $REDHAT_RELEASE =~ "CentOS" || $REDHAT_RELEASE =~ "Red Hat Enterprise Linux" ]]
    then
        $SUDO_FLAG yum install curl jq -q -y
    else
        UNSUPPORTED_SYSTEM=$REDHAT_RELEASE
    fi
elif hash lsb_release 2> /dev/null
then
    if [ "E`lsb_release -i --short`" = "EUbuntu" ]
    then
        $SUDO_FLAG apt-get install curl jq -q=2
    else
        UNSUPPORTED_SYSTEM=`lsb_release -d -s`
    fi
fi

if [ E$UNSUPPORTED_SYSTEM != "E" ]
then
    echo "This program only supports Ubuntu and CentOS (RHEL). "
    echo "$UNSUPPORTED_SYSTEM is unsupported. "
    exit 255
fi

LATEST_VERSION=`curl -fsSL https://api.github.com/repos/stevapple/swiftbox/releases/latest | jq .tag_name | sed "s/v//" | sed "s/\"//g"`
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