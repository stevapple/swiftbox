#!/bin/bash

if [ "E`lsb_release -i --short`" = "EUbuntu" ]
then
    UBUNTU_VERSION=`lsb_release -i --short`
else
    echo "This program only support Ubuntu. "
    exit 255
fi

SWIFTENV_VERSION="0.3.1"

init-env() {
    mkdir $WORKING_DIR
    echo "Created swiftenv working directory at $WORKING_DIR. "
    echo "if [ -e $WORKING_DIR/.swift-version ]\nthen\n\texport PATH=$WORKING_DIR/toolchain/swift-\`cat $WORKING_DIR/.swift-version\`/usr/bin:\$PATH\nfi" > $WORKING_DIR/env.sh
    if [ $IS_SUDO -eq 0 ]
        then
        if [ -e $HOME/.zshrc ]
        then
            echo "source $WORKING_DIR/env.sh" >> $HOME/.zshrc
        fi
        if [ -e $HOME/.bashrc ]
        then
            echo "source $WORKING_DIR/env.sh" >> $HOME/.bashrc
        elif [ -e $HOME/.bash_profile ]
        then
            echo "source $WORKING_DIR/env.sh" >> $HOME/.bash_profile
        fi
    else
        ln -s $WORKING_DIR/env.sh /etc/profile.d/swiftenv.sh
    fi
    $SUDO_FLAG apt-get update
    $SUDO_FLAG apt-get install clang libicu-dev wget -y
    wget -q -O https://swift.org/keys/all-keys.asc | gpg --import -
    echo "swiftenv has been successfully set up. "
}

format-version() {
    if [ "E$1" = E ]
    then
        echo "Please specify Swift version. "
        return 12
    fi
    local VERSION_ARRAY=(${1//./ })
    for var in ${VERSION_ARRAY[@]}
    do
        if [ `echo $var | sed 's/[0-9]//g'` ]
        then
            echo "Invalid Swift version, try x.x.x or x.x"
            return 1
        fi
    done
    case ${#VERSION_ARRAY[@]} in
    2)
        echo "$((10#${VERSION_ARRAY[0]})).$((10#${VERSION_ARRAY[1]}))"
    ;;
    3)
        if [ ${VERSION_ARRAY[2]} -eq 0 ]
        then
            echo "$((10#${VERSION_ARRAY[0]})).$((10#${VERSION_ARRAY[1]}))"
        else
            echo "$((10#${VERSION_ARRAY[0]})).$((10#${VERSION_ARRAY[1]})).$((10#${VERSION_ARRAY[2]}))"
        fi
    ;;
    *)
        echo "Invalid Swift version, try x.x.x or x.x"
        return 1
    ;;
    esac
}

uninstall-swift() {
    if [ ! -d $WORKING_DIR/toolchain/swift-$1 ]
    then
        echo "This version has not been installed, you can install it with: $0 install $1"
        return 4
    else
        rm -rf $WORKING_DIR/toolchain/swift-$1
        if [ E`default-version` = E$1 ]
        then
            detach-swift
        fi
        echo "Successfully uninstalled Swift $1. "
    fi
}

default-version() {
    if [ ! -e $WORKING_DIR/.swift-version ]
    then 
        echo ""
    else
        cat $WORKING_DIR/.swift-version
    fi
}

check-version() {
    local DOWNLOAD_URL="https://swift.org/builds/swift-$1-release/ubuntu${UBUNTU_VERSION//./}/swift-$1-RELEASE/swift-$1-RELEASE-ubuntu$UBUNTU_VERSION.tar.gz"
    wget --no-check-certificate -q --spider $DOWNLOAD_URL
    WGET_RESULT=$?
    if [ $WGET_RESULT -eq 8 ]
    then
        echo "The Swift version does not exist or does not support your Ubuntu version. "
        return 2
    elif [ $WGET_RESULT -ge 4 ]
    then
        echo "Network error. Please check your Internet connection and proxy settings. "
        return 5
    elif [ $WGET_RESULT -ge 1 ]
    then
        echo "Please check your wget config. "
        return 255
    fi
}

install-swift() {
    cd $WORKING_DIR
    local NEW_VERSION=$1
    local FILE_NAME="swift-$NEW_VERSION-RELEASE-ubuntu$UBUNTU_VERSION"
    local DOWNLOAD_URL="https://swift.org/builds/swift-$NEW_VERSION-release/ubuntu${UBUNTU_VERSION//./}/swift-$NEW_VERSION-RELEASE/$FILE_NAME.tar.gz"
    check-version $NEW_VERSION
    VERSION_AVAILABILITY=$?
    if [ ! $VERSION_AVAILABILITY -eq 0 ]
    then
        return $VERSION_AVAILABILITY
    fi
    if [ -e "download/$FILE_NAME.tar.gz.sig" ]
    then
        wget -c -t 5 -P download "$DOWNLOAD_URL.sig"
    else
        if [ -e "download/$FILE_NAME.tar.gz" ]
        then
            wget -c -t 0 -P download $DOWNLOAD_URL
        else
            wget -t 5 -P download $DOWNLOAD_URL
        fi
        wget -t 5 -P download "$DOWNLOAD_URL.sig"
    fi
    gpg --keyserver hkp://pool.sks-keyservers.net --refresh-keys Swift
    gpg --verify $FILE_NAME.tar.gz.sig
    tar -xzf "download/$FILE_NAME.tar.gz" -C "temp"
    mv "temp/$FILE_NAME" "toolchain/swift-$NEW_VERSION"
    if [ ! -e .swift-version ]
    then
        echo "Automatically set Swift $NEW_VERSION as default. "
        attach-version $NEW_VERSION
    fi
}

attach-version() {
    is-installed $1
    if [ $? -eq 0 ]
    then
        echo $1 > $WORKING_DIR/.swift-version
        source $WORKING_DIR/env.sh
        echo "Successfully attached Swift version $1. "
    else
        echo "Attach error: This version has not been installed yet. "
        return 20
    fi
}

is-installed() {
    if [ -d $WORKING_DIR/toolchain/swift-$1 ]
    then
        return 0
    else
        return 1
    fi
}

ensure-env() {
    if [ ! -e $WORKING_DIR ]
    then
        echo "It seems you're using swiftenv for the very first time. Let's set up the supporting environment. "
        init-env
    else
        rm -rf $WORKING_DIR/temp/*
    fi
}

detach-swift() {
    local SWIFT_VERSION=`default-version`
    if [ E$SWIFT_VERSION = "E" ]
    then
        echo "No Swift version is attached yet. "
        return 10
    else
        rm -f $WORKING_DIR/.swift-version
        echo "Successfully detached Swift version $SWIFT_VERSION. "
    fi
}

if [ `id -u` -eq 0 ]
then
    IS_SUDO=1
    WORKING_DIR="/opt/swift"
else
    IS_SUDO=0
    WORKING_DIR="$HOME/.swiftenv"
    SUDO_FLAG="sudo"
fi

if [ $# -eq 0 ]
then
    echo "Please specify a command. "
    exit 240
fi

case $1 in
install)
    ensure-env
    FORMAT_VERSION=`format-version $2`
    FORMAT_RESULT=$?
    if [ ! $FORMAT_RESULT -eq 0 ]
    then
        echo $FORMAT_VERSION
        exit $FORMAT_RESULT
    fi
    is-installed $FORMAT_VERSION
    if [ $? -eq 0 ]
    then
        echo "This version is already installed, you can reinstall it with: $0 reinstall $FORMAT_VERSION"
        exit 4
    else
        install-swift $FORMAT_VERSION
    fi
;;
reinstall)
    ensure-env
    FORMAT_VERSION=`format-version $2`
    FORMAT_RESULT=$?
    if [ ! $FORMAT_RESULT -eq 0 ]
    then
        echo $FORMAT_VERSION
        exit $FORMAT_RESULT
    else
        UNINSTALL_MESSAGE=`uninstall-swift $FORMAT_VERSION`
        UNINSTALL_RESULT=$?
        if [ ! $UNINSTALL_RESULT -eq 0 ]
        then
            echo $UNINSTALL_MESSAGE
            exit $UNINSTALL_RESULT
        else
            install-swift $FORMAT_VERSION
            exit $?
        fi
    fi
;;
uninstall)
    ensure-env
    FORMAT_VERSION=`format-version $2`
    FORMAT_RESULT=$?
    if [ ! $FORMAT_RESULT -eq 0 ]
    then
        echo $FORMAT_VERSION
        exit $FORMAT_RESULT
    else
        uninstall-swift $FORMAT_VERSION
        exit $?
    fi
;;
attach)
    FORMAT_VERSION=`format-version $2`
    FORMAT_RESULT=$?
    if [ ! $FORMAT_RESULT -eq 0 ]
    then
        echo $FORMAT_VERSION
        exit $FORMAT_RESULT
    else
        attach-version $FORMAT_VERSION
        exit $?
    fi
;;
clean)
    ensure-env
    rm -rf $WORKING_DIR/temp/*
    rm -rf $WORKING_DIR/download/*
;;
detach)
    detach-swift
    exit $?
;;
version)
    echo $SWIFTENV_VERSION
;;
find)
    FORMAT_VERSION=`format-version $2`
    FORMAT_RESULT=$?
    if [ ! $FORMAT_RESULT -eq 0 ]
    then
        echo $FORMAT_VERSION
        exit $FORMAT_RESULT
    fi
    check-version $FORMAT_VERSION
    VERSION_AVAILABILITY=$?
    if [ ! $VERSION_AVAILABILITY -eq 0 ]
    then
        exit $VERSION_AVAILABILITY
    fi
    echo "Version $FORMAT_VERSION is available for Ubuntu $UBUNTU_VERSION. "
;;
update)
    INSTALL_SCRIPT=`wget -q -O- https://raw.githubusercontent.com/stevapple/swiftenv/master/install.sh`
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
    sh -c $INSTALL_SCRIPT
    exit $?
;;
versions)
    ensure-env
    for file in `ls -1 $WORKING_DIR/toolchain`
    do
        if [ -d "$WORKING_DIR/toolchain/$file" ]
        then
            if [ $file = "swift-`default-version`" ]
            then
                echo "* ${file#swift\-}"
            else
                echo "- ${file#swift\-}"
            fi
        fi
    done
;;
*)
    echo "Unsupported command: $1"
    exit 3
;;
esac