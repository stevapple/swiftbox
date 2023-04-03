#!/bin/bash

if [ `id -u` != 0 ] && hash sudo 2> /dev/null
then
    SUDO_FLAG="sudo"
fi

if [ -f /etc/os-release ]
then
    OS=`cat /etc/os-release | grep '^ID=' | sed 's/ID=//g' | sed 's/"//g'`
    case $OS in
    ubuntu)
        if hash curl 2> /dev/null || ! hash jq 2> /dev/null
        then
            $SUDO_FLAG apt-get update -q=2
            $SUDO_FLAG apt-get install curl jq -q=2
        fi
    ;;
    rhel | centos | amzn)
        VERSION=`cat /etc/os-release | grep '^VERSION_ID=' | sed 's/VERSION_ID=//g' | sed 's/"//g'`
        if ! hash curl 2> /dev/null || ! hash jq 2> /dev/null || ! hash which 2> /dev/null
        then
            if [ $OS != 'amzn' ] && [ $VERSION -lt 8 ]
            then
                $SUDO_FLAG yum install epel-release -y &> /dev/null
            fi
            $SUDO_FLAG yum install curl jq which -y &> /dev/null
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
INSTALL_PATH="/usr/bin/swiftbox"

if [ ! "$LATEST_VERSION" ]
then
    echo "Please check your Internet connection, especially GitHub availability."
    exit 4
fi

if hash swiftbox 2> /dev/null
then
    UPGRADE_COMMAND="upgrade"
    SWIFTBOX_VERSION=`swiftbox -v`
    if [ $? != 0 ]
    then
        UPGRADE_COMMAND="update"
        SWIFTBOX_VERSION=`swiftbox version`
    fi
    echo "swiftbox $SWIFTBOX_VERSION is already installed in $(dirname `which swiftbox`)"
    read -p "Input 'yes' or 'y' to upgrade, anything else to do a fresh installation: " PROMPT
    case $PROMPT in
    [yY][eE][sS] | [yY])
        swiftbox $UPGRADE_COMMAND
        exit
    ;;
    esac
fi

if [ -d $INSTALL_PATH ]
then
    echo "Unexpected directory at $INSTALL_PATH"
    exit 254
fi

SWIFTBOX_URL="https://cdn.jsdelivr.net/gh/stevapple/swiftbox@$LATEST_VERSION/swiftbox.sh"
echo "Downloading swiftbox $LATEST_VERSION from $SWIFTBOX_URL"
$SUDO_FLAG curl -o $INSTALL_PATH $SWIFTBOX_URL -#

CURL_RESULT=$?
if [ $CURL_RESULT != 0 ]
then
    echo "Download failed, please check your Internet connection."
    exit $CURL_RESULT
fi

$SUDO_FLAG chmod +x $INSTALL_PATH
echo "Successfully installed swiftbox $LATEST_VERSION in `dirname $INSTALL_PATH`"
