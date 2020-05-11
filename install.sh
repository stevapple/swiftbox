#!/bin/bash

if [ `id -u` != 0 ]
then
    SUDO_FLAG="sudo"
fi

if [ -f /etc/redhat-release ]
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
    if [ `lsb_release -i --short` = "Ubuntu" ]
    then
        $SUDO_FLAG apt-get install curl jq -q=2
    else
        UNSUPPORTED_SYSTEM=`lsb_release -d -s`
    fi
elif hash uname 2> /dev/null
then
    UNSUPPORTED_SYSTEM=`uname -v`
else
    UNSUPPORTED_SYSTEM="This strange OS"
fi

if [ $UNSUPPORTED_SYSTEM ]
then 
    echo "This program only supports Ubuntu and CentOS (RHEL). "
    echo "$UNSUPPORTED_SYSTEM is unsupported. "
    exit 255
fi

LATEST_VERSION=`curl -fsSL https://api.github.com/repos/stevapple/swiftbox/releases/latest | jq .tag_name | sed "s/v//" | sed "s/\"//g"`
INSTALL_DIR="/usr/bin"

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
    if [ $SWIFTBOX_VERSION = $LATEST_VERSION ]
    then
        echo "Already installed the latest version $SWIFTBOX_VERSION at $INSTALL_DIR. "
        exit
    fi
    SUCCESS_MESSAGE="Successfully upgraded swiftbox from $SWIFTBOX_VERSION to $LATEST_VERSION. "
else
    SUCCESS_MESSAGE="Successfully installed swiftbox $LATEST_VERSION at $INSTALL_DIR. "
fi

$SUDO_FLAG curl -o $INSTALL_DIR/swiftbox https://cdn.jsdelivr.net/gh/stevapple/swiftbox@$LATEST_VERSION/swiftbox.sh
$SUDO_FLAG chmod +x $INSTALL_DIR/swiftbox
hash -r
echo $SUCCESS_MESSAGE