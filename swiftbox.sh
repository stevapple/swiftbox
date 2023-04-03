#!/bin/bash

## Set environment properties

SWIFTBOX_VERSION="0.13.4"
SWIFT_DOWNLOAD_SITE="https://download.swift.org"

if [ `id -u` = 0 ]
then
    WORKING_DIR="/opt/swiftbox"
    ANOTHER_WD="$HOME/.swiftbox"
    SCHEME="[global]"
else
    WORKING_DIR="$HOME/.swiftbox"
    ANOTHER_WD="/opt/swiftbox"
    SCHEME="[`whoami`]"
    if hash sudo 2> /dev/null
    then
        SUDO_FLAG="sudo"
    fi
fi

## Judge OS and install dependencies

if [ -f /etc/os-release ]
then
    source /etc/os-release
    SYSTEM_NICENAME=$NAME
    if [ E$SWIFTBOX_SYSALIAS != E ]
    then
        SYSTEM_VERSION=$SWIFTBOX_SYSALIAS
    elif [ -f $WORKING_DIR/.system-alias ]
    then
        SYSTEM_VERSION=`cat $WORKING_DIR/.system-alias`
    else
        SYSTEM_VERSION=$VERSION_ID
    fi
    case $ID in
    ubuntu)
        SYSTEM_NAME="ubuntu"
        if ! hash curl 2> /dev/null || ! hash realpath 2> /dev/null || ! hash wget 2> /dev/null || ! hash jq 2> /dev/null
        then
            $SUDO_FLAG apt-get update -q=2
            $SUDO_FLAG apt-get install coreutils curl wget jq -q=2
        fi
    ;;
    rhel | centos)
        SYSTEM_NAME="centos"
        if ! hash curl 2> /dev/null || ! hash wget 2> /dev/null || ! hash jq 2> /dev/null
        then
            if [ $SYSTEM_VERSION -lt 8 ]
            then
                $SUDO_FLAG yum install epel-release -y &> /dev/null
            fi
            $SUDO_FLAG yum install curl wget jq -y &> /dev/null
        fi
    ;;
    amzn)
        SYSTEM_NAME="amazonlinux"
        if ! hash curl 2> /dev/null || ! hash wget 2> /dev/null || ! hash jq 2> /dev/null
        then
            $SUDO_FLAG yum install curl wget jq -y &> /dev/null
        fi
    ;;
    *)
        UNSUPPORTED_SYSTEM="$NAME $VERSION"
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

# Check the environment

if hash uname 2> /dev/null
then
    ARCH=`uname -i`
elif hash arch 2> /dev/null
then
    ARCH=`arch`
else
    echo "warning: failed to detect CPU architecture, assuming x86_64"
    ARCH="x86_64"
fi

if [ $ARCH != "x86_64" ]
then
    ARCH_SUFFIX="-$ARCH"
fi

INSTALL_DIR=`dirname $0`
PATHS=(${PATH//:/ })
PROGRAM=$0
for PATH_DIR in ${PATHS[@]}
do
    if [ $PATH_DIR = $INSTALL_DIR ]
    then
        PROGRAM=`basename $0`
    fi
done

## Configure the environment

init-env() {
    mkdir $WORKING_DIR
    mkdir $WORKING_DIR/temp
    mkdir $WORKING_DIR/toolchain
    mkdir $WORKING_DIR/download
    echo "$SCHEME Created swiftbox working directory at $WORKING_DIR"
    echo -e "if [ -f $WORKING_DIR/.swift-version ]\nthen\n\texport PATH=$WORKING_DIR/toolchain/swift-\`cat $WORKING_DIR/.swift-version\`/usr/bin:\$PATH\nfi" > $WORKING_DIR/env.sh
    if [ `id -u` = 0 ]
    then
        $SUDO_FLAG ln -s $WORKING_DIR/env.sh /etc/profile.d/swiftbox.sh
    fi
    enable-swiftbox
    case $SYSTEM_NAME in
    ubuntu)
        $SUDO_FLAG apt-get update
        case $SYSTEM_VERSION in
        16.04 | 18.04 | 20.04 | 22.04) ;;
        *)
            echo "It seems you're using an unsupported Ubuntu version. Dependency installation might fail."
        ;;
        esac
        COMMON_DEPS="binutils git gnupg2 libc6-dev libedit2 libsqlite3-0 pkg-config tzdata zlib1g-dev"
        case $SYSTEM_VERSION in
        16.04 | 18.04)
            FOUNDATION_DEPS="libcurl4 libxml2 libicu-dev"
            GCC_DEPS="libgcc-5-dev libstdc++-5-dev"
            PYTHON_DEP="libpython2.7"
        ;;
        20.04)
            FOUNDATION_DEPS="libcurl4 libxml2"
            GCC_DEPS="libgcc-9-dev libstdc++-9-dev"
            PYTHON_DEP="libpython2.7"
            OTHER_DEPS="uuid-dev"
        ;;
        22.04 | *)
            FOUNDATION_DEPS="libcurl4-openssl-dev libxml2-dev"
            GCC_DEPS="libgcc-9-dev libstdc++-9-dev"
            PYTHON_DEP="libpython3.8"
            OTHER_DEPS="unzip"
        ;;
        esac
        $SUDO_FLAG apt-get install $COMMON_DEPS $FOUNDATION_DEPS $GCC_DEPS $PYTHON_DEP $OTHER_DEPS -y
    ;;
    centos)
        $SUDO_FLAG yum install binutils gcc git libedit libicu-devel pkg-config python2 sqlite zlib-devel -y
        case $SYSTEM_VERSION in
        7)
            $SUDO_FLAG yum install shadow-utils libbsd-devel glibc-static libstdc++-static libedit-devel -y
            sed -i -e 's/\*__block/\*__libc_block/g' /usr/include/unistd.h
        ;;
        8)
            $SUDO_FLAG yum install epel-release -y
            $SUDO_FLAG yum install --enablerepo=PowerTools libbsd-devel glibc-static libstdc++-static libedit-devel -y
        ;;
        esac
    ;;
    amazonlinux)
        $SUDO_FLAG yum install binutils gcc git glibc-static gzip libbsd libcurl libedit libicu sqlite libstdc++-static libuuid libxml2 tar tzdata -y
    ;;
    esac
    wget -q -O - https://swift.org/keys/all-keys.asc | $SUDO_FLAG gpg --import -
    echo "$SCHEME swiftbox has been successfully set up."
}

ensure-env() {
    if [ ! -d $WORKING_DIR ]
    then
        echo "$SCHEME It seems you're using swiftbox for the very first time. Let's set up the supporting environment."
        init-env
    else
        if [ E`default-version` != E ]
        then
            hash swift 2> /dev/null || enable-swiftbox
        fi
        hash -r
        rm -rf $WORKING_DIR/temp/*
    fi
}

enable-swiftbox() {
    if [ -f $ANOTHER_WD/env.sh ]
    then
        if [ -f $HOME/.zshrc ]
        then
            reinit-env $HOME/.zshrc
        fi
        if [ -f $HOME/.bashrc ]
        then
            reinit-env $HOME/.bashrc
        fi
        if [ -f $HOME/.bash_profile ]
        then
            reinit-env $HOME/.bash_profile
        fi
    else
        if [ -f $HOME/.zshrc ]
        then
            echo "source $WORKING_DIR/env.sh" >> $HOME/.zshrc
        fi
        if [ -f $HOME/.bashrc ]
        then
            echo "source $WORKING_DIR/env.sh" >> $HOME/.bashrc
        fi
        if [ -f $HOME/.bash_profile ]
        then
            echo "source $WORKING_DIR/env.sh" >> $HOME/.bash_profile
        fi
    fi
}

reinit-env() {
    sed -i "#$WORKING_DIR\/env.sh#d;#$ANOTHER_WD\/env.sh#d" $1
    echo "source /opt/swiftbox/env.sh" >> $1
    echo "source $HOME/.swiftbox/env.sh" >> $1
}

## Parse and check Swift version

download-base() {
    echo $SWIFT_DOWNLOAD_SITE/$1/$SYSTEM_NAME${SYSTEM_VERSION//./}$ARCH_SUFFIX
}

format-version() {
    if [ ! $1 ]
    then
        echo "Please specify Swift version."
        return 12
    fi
    local VERSION_ARRAY=(${1//./ })
    for var in ${VERSION_ARRAY[@]}
    do
        if [ `echo $var | sed 's/[0-9]//g'` ]
        then
            echo "Invalid Swift version, try x.x.x, x.x or nightly."
            return 1
        fi
    done
    case ${#VERSION_ARRAY[@]} in
    2)
        echo "$((10#${VERSION_ARRAY[0]})).$((10#${VERSION_ARRAY[1]}))"
    ;;
    3)
        if [ ${VERSION_ARRAY[2]} = 0 ]
        then
            echo "$((10#${VERSION_ARRAY[0]})).$((10#${VERSION_ARRAY[1]}))"
        else
            echo "$((10#${VERSION_ARRAY[0]})).$((10#${VERSION_ARRAY[1]})).$((10#${VERSION_ARRAY[2]}))"
        fi
    ;;
    *)
        echo "Invalid Swift version, try x.x.x or x.x or nightly."
        return 1
    ;;
    esac
}

check-version() {
    local DOWNLOAD_URL=`download-base swift-$NEW_VERSION-release`/swift-$NEW_VERSION-RELEASE/swift-$NEW_VERSION-RELEASE-$SYSTEM_NAME$SYSTEM_VERSION$ARCH_SUFFIX.tar.gz
    wget --no-check-certificate -q --spider $DOWNLOAD_URL
    local WGET_RESULT=$?
    if [ $WGET_RESULT = 8 ]
    then
        echo "Swift $NEW_VERSION does not exist or does not support your $SYSTEM_NICENAME version."
        return 2
    elif [ $WGET_RESULT -ge 4 ]
    then
        echo "Network error. Please check your Internet connection and proxy settings."
        return 5
    elif [ $WGET_RESULT -ge 1 ]
    then
        echo "Please check your wget config."
        return 255
    fi
}

nightly-version() {
    local YML_URL=`download-base development`/latest-build.yml
    wget --no-check-certificate -q --spider $YML_URL
    local WGET_RESULT=$?
    if [ $WGET_RESULT = 8 ]
    then
        echo "Current nightly builds don't support your $SYSTEM_NICENAME version."
        return 2
    elif [ $WGET_RESULT -ge 4 ]
    then
        echo "Network error. Please check your Internet connection and proxy settings."
        return 5
    elif [ $WGET_RESULT -ge 1 ]
    then
        echo "Please check your wget config."
        return 255
    fi
    curl -s $YML_URL | grep 'download:' | sed 's/download:[^:\/\/]//g' | sed 's/swift-DEVELOPMENT-SNAPSHOT-//' | sed "s/-$SYSTEM_NAME$SYSTEM_VERSION$ARCH_SUFFIX.tar.gz//"
}

## Install Swift toolchains

fetch-release() {
    cd $WORKING_DIR
    FILE_NAME="swift-$NEW_VERSION-RELEASE-$SYSTEM_NAME$SYSTEM_VERSION$ARCH_SUFFIX"
    DOWNLOAD_URL=`download-base swift-$NEW_VERSION-release`/swift-$NEW_VERSION-RELEASE/$FILE_NAME.tar.gz
    check-version
    local VERSION_AVAILABILITY=$?
    if [ $VERSION_AVAILABILITY != 0 ]
    then
        return $VERSION_AVAILABILITY
    fi
    install-toolchain
}

fetch-snapshot() {
    cd $WORKING_DIR
    FILE_NAME="swift-DEVELOPMENT-SNAPSHOT-$NEW_VERSION-$SYSTEM_NAME$SYSTEM_VERSION$ARCH_SUFFIX"
    DOWNLOAD_URL=`download-base development`/swift-DEVELOPMENT-SNAPSHOT-$NEW_VERSION/$FILE_NAME.tar.gz
    install-toolchain
}

install-toolchain() {
    if [ -f download/$FILE_NAME.tar.gz.sig ]
    then
        wget -t 5 -P download $DOWNLOAD_URL.sig -O download/$FILE_NAME.tar.gz.sig
    else
        if [ -f download/$FILE_NAME.tar.gz ]
        then
            echo "Download cache found in $WORKING_DIR/download, resume."
            wget -c -t 0 -P download $DOWNLOAD_URL
        elif [ -f $ANOTHER_WD/download/$FILE_NAME.tar.gz ]
        then
            cp $ANOTHER_WD/download/$FILE_NAME.tar.gz download/
            chown `whoami` download/$FILE_NAME.tar.gz
            echo "Download cache found in $ANOTHER_WD/download, copy and resume."
            wget -c -t 0 -P download $DOWNLOAD_URL
        else
            wget -t 5 -P download $DOWNLOAD_URL
        fi
        wget -t 5 -P download $DOWNLOAD_URL.sig
    fi
    $SUDO_FLAG gpg --keyserver hkp://keyserver.ubuntu.com --refresh-keys Swift
    $SUDO_FLAG gpg --verify download/$FILE_NAME.tar.gz.sig
    if [ $? != 0 ]
    then
        echo "Signature check failed, please try again."
        echo "If it always fails, clear the cache with: $PROGRAM cleanup"
        exit 100
    fi
    tar -xzf download/$FILE_NAME.tar.gz -C temp
    if [ -d temp/$FILE_NAME ]
    then
        mv temp/$FILE_NAME toolchain/swift-$NEW_VERSION
    else
        mv temp toolchain/swift-$NEW_VERSION
        mkdir temp
    fi
    chmod -R o+r toolchain/swift-$NEW_VERSION/usr/lib/swift
    echo $SYSTEM_VERSION > $WORKING_DIR/toolchain/$file/.system-version
}

## Manage local toolchains

is-kept() {
    if [ -d $WORKING_DIR/toolchain/swift-$1 ]
    then
        return 0
    else
        return 1
    fi
}

default-version() {
    if [ ! -f $WORKING_DIR/.swift-version ]
    then
        echo ""
    else
        cat $WORKING_DIR/.swift-version
    fi
}

select-version() {
    is-kept $1
    if [ $? = 0 ]
    then
        echo $1 > $WORKING_DIR/.swift-version
        ensure-env
        echo "$SCHEME Now using Swift $1"
    else
        echo "$SCHEME Swift $1 has not been kept."
        echo "You can get it with: $PROGRAM get $1"
        return 20
    fi
}

remove-swift() {
    if [ ! -d $WORKING_DIR/toolchain/swift-$1 ]
    then
        echo "$SCHEME Swift $1 has not been kept."
        echo "You can get it with: $PROGRAM get $1"
        return 4
    else
        rm -rf $WORKING_DIR/toolchain/swift-$1
        if [ E`default-version` = E$1 ]
        then
            disable-swift
        fi
        echo "$SCHEME Successfully removed Swift $1"
    fi
}

disable-swift() {
    local SWIFT_VERSION=`default-version`
    rm -f $WORKING_DIR/.swift-version
    ensure-env
    if [ ! $SWIFT_VERSION ]
    then
        echo "$SCHEME Swift $SWIFT_VERSION is now disabled."
    fi
}

## Main entry

if [ $# = 0 ]
then
    echo "Please specify a command."
    exit 240
fi

case $1 in
check)
    if [ E$2 = E`default-version` ]
    then
        echo "$SCHEME Swift $2 is kept locally and already set to default."
    elif [ `is-kept $2` ]
    then
        echo "$SCHEME Swift $2 is kept locally."
        echo "You can enable it with: $PROGRAM use $2"
    else
        if [ E$2 = "Enightly" ]
        then
            NEW_VERSION=`nightly-version`
        else
            NEW_VERSION=`format-version $2`
        fi
        FORMAT_RESULT=$?
        if [ $FORMAT_RESULT != 0 ]
        then
            echo $NEW_VERSION
            exit $FORMAT_RESULT
        fi
        if [ E$2 = "Enightly" ]
        then
            echo "Swift nightly build $NEW_VERSION is available for $SYSTEM_NICENAME $SYSTEM_VERSION"
            echo "You can get it with: $PROGRAM get nightly"
        else
            check-version
            VERSION_AVAILABILITY=$?
            if [ $VERSION_AVAILABILITY != 0 ]
            then
                exit
            fi
            echo "Swift $NEW_VERSION is available for $SYSTEM_NICENAME $SYSTEM_VERSION"
            echo "You can get it with: $PROGRAM get $NEW_VERSION"
        fi
    fi
;;
get)
    ensure-env
    if [ E$2 = "Enightly" ]
    then
        NEW_VERSION=`nightly-version`
        FORMAT_RESULT=$?
        TOOLCHAIN_TYPE="snapshot"
    else
        NEW_VERSION=`format-version $2`
        FORMAT_RESULT=$?
        TOOLCHAIN_TYPE="release"
    fi
    if [ $FORMAT_RESULT != 0 ]
    then
        echo $NEW_VERSION
        exit $FORMAT_RESULT
    fi
    if [ E$NEW_VERSION = E`default-version` ]
    then
        echo "$SCHEME Swift $NEW_VERSION is kept locally and already set to default."
        exit 34
    elif [ `is-kept $NEW_VERSION` ]
    then
        echo "$SCHEME Swift $NEW_VERSION is kept locally."
        echo "You can enable it with: $PROGRAM use $NEW_VERSION"
        exit 33
    else
        fetch-$TOOLCHAIN_TYPE $NEW_VERSION
        FETCH_RESULT=$?
        if [ $FETCH_RESULT != 0 ]
        then
            exit $FETCH_RESULT
        fi
        echo "$SCHEME Swift $NEW_VERSION is ready for use!"
        if [ ! -f .swift-version ]
        then
            echo "$SCHEME Automatically set Swift $NEW_VERSION as default."
            select-version $NEW_VERSION
        fi
    fi
;;
list)
    ensure-env
    for file in `ls -1 $WORKING_DIR/toolchain`
    do
        if [ -d $WORKING_DIR/toolchain/$file ]
        then
            if [ ! -f $WORKING_DIR/toolchain/$file/.system-version ]
            then
                echo $VERSION_ID > $WORKING_DIR/toolchain/$file/.system-version
            fi
            version=`cat $WORKING_DIR/toolchain/$file/.system-version`
            if [ $version = $VERSION_ID ]
            then
                SUFFIX=""
            else
                SUFFIX=" ($SYSTEM_NICENAME $version)"
            fi
            if [ $file = swift-`default-version` ]
            then
                echo "* ${file#swift\-}$SUFFIX"
            else
                echo "- ${file#swift\-}$SUFFIX"
            fi
        fi
    done
;;
use)
    select-version $2
    exit $?
;;
remove)
    ensure-env
    remove-swift $2
    exit $?
;;
close)
    disable-swift
    exit $?
;;
cleanup)
    ensure-env
    rm -rf $WORKING_DIR/temp/*
    rm -rf $WORKING_DIR/download/*
    echo "$SCHEME Successfully cleaned the cache."
;;
upgrade)
    SWIFTBOX_PATH=`realpath $0`
    LATEST_VERSION=`curl -fsSL https://api.github.com/repos/stevapple/swiftbox/releases/latest | jq .tag_name | sed "s/v//" | sed "s/\"//g"`
    if [ ! "$LATEST_VERSION" ]
    then
        echo "Please check your Internet connection, especially GitHub availability."
        exit 4
    elif [ $SWIFTBOX_VERSION = $LATEST_VERSION ]
    then
        echo "swiftbox $SWIFTBOX_VERSION is up to date."
        exit
    fi
    SWIFTBOX_URL="https://cdn.jsdelivr.net/gh/stevapple/swiftbox@$LATEST_VERSION/swiftbox.sh"
    echo "Downloading swiftbox $LATEST_VERSION from $SWIFTBOX_URL"
    $SUDO_FLAG curl -o "$SWIFTBOX_PATH.downloading" $SWIFTBOX_URL -#
    CURL_RESULT=$?
    if [ $CURL_RESULT != 0 ]
    then
        echo "Download failed, please check your Internet connection."
    else
        $SUDO_FLAG sh -c "cat $SWIFTBOX_PATH.downloading > $SWIFTBOX_PATH"
        echo "Successfully upgraded swiftbox from $SWIFTBOX_VERSION to $LATEST_VERSION"
    fi
    $SUDO_FLAG rm -f $SWIFTBOX_PATH.downloading
    exit $CURL_RESULT
;;
-v | --version)
    if [ $VERSION_ID = $SYSTEM_VERSION ]
    then
        echo $SWIFTBOX_VERSION
    else
        echo "$SWIFTBOX_VERSION ($SYSTEM_NICENAME $SYSTEM_VERSION)"
    fi
;;
-h | --help)
    cat <<EOF
swiftbox: Use Swift out of the Box on Ubuntu, CentOS(RHEL) and Amazon Linux

Usage: swiftbox [option]
       swiftbox [command] ...

Options:
  -v, --version      Show swiftbox and system (alias) version
    -s, --short      Show only swiftbox version
  -h, --help         Show help page

Commands:
  check <version>    Check the availability of Swift <version>
        nightly      Check the availability of Swift nightly builds
  get <version>      Get Swift <version> from swift.org
      nightly        Get the latest nightly build from swift.org
  list               List Swift versions on the computer
  use <version>      Select Swift <version> as default
  remove <version>   Remove swift <version> from the computer
  close              Disable Swift managed by swiftbox
  cleanup            Clear swiftbox download cache
  upgrade            Upgrade swiftbox to the latest version
EOF
;;
*)
    if [[ $1 == -* ]]
    then
        echo "Invalid option: $1"
    else
        echo "Illegal command: $1"
    fi
    echo "Use '$PROGRAM -h' for help."
    exit 3
;;
esac
