#!/bin/bash

if [ "E`lsb_release -i --short`" = "EUbuntu" ]
then
    UBUNTU_VERSION=`lsb_release -i --short`
else
    echo "This program only support Ubuntu. "
    exit 255
fi

SWIFTENV_VERSION="0.2"

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
    local VERSION_ARRAY=(${1//./ })
    for var in ${VERSION_ARRAY[@]}
    do
        if [ `echo $var | sed 's/[0-9]//g'` ]
        then
            echo "Invalid Swift version, try format x.x.x or x.x"
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
        echo "Invalid Swift version, try format x.x.x or x.x"
        return 1
    ;;
    esac
}

uninstall-swift() {
    if [ ! -d $WORKING_DIR/toolchain/swift-$FORMAT_VERSION ]
    then
        echo "This version has not been installed, you can install it with: $0 install $FORMAT_VERSION"
        return 4
    else
        rm -rf toolchain/swift-$FORMAT_VERSION
        if [ E`default-version` = E$FORMAT_VERSION ]
        then
            rm $WORKING_DIR/.swift-version
        fi
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

install-swift() {
    cd $WORKING_DIR
    local NEW_VERSION=$1
    local FILE_NAME="swift-$NEW_VERSION-RELEASE-ubuntu$UBUNTU_VERSION"
    local DOWNLOAD_URL="https://swift.org/builds/swift-$NEW_VERSION-release/ubuntu${UBUNTU_VERSION//./}/swift-$NEW_VERSION-RELEASE/$FILE_NAME.tar.gz"
    wget --no-check-certificate -q --spider $DOWNLOAD_URL
    if [ $? -eq 8 ]
    then
        echo "The Swift version does not exist or does not support your Ubuntu version. "
        exit 2
    elif [ $? -ge 4]
    then
        echo "Network error. Please check your Internet connection and proxy settings. "
        exit 5
    elif [ $? -ge 1]
    then
        echo "Please check your wget config. "
        exit 255
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
    echo $1 > $WORKING_DIR/.swift-version
    source $WORKING_DIR/env.sh
}

is-installed() {
    if [ -d $WORKING_DIR/toolchain/swift-$1 ]
    then
        return 1
    else
        return 0
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
    exit
fi

case $1 in
install)
    ensure-env
    FORMAT_VERSION=`format-version $2`
    if [ ! $? -eq 0 ]
    then
        echo $FORMAT_VERSION
        exit 1
    fi
    is-installed $FORMAT_VERSION
    if [ ! $? -eq 0 ]
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
    if [ ! $? -eq 0 ]
    then
        echo $FORMAT_VERSION
        exit 1
    else
        UNINSTALL_MESSAGE=`uninstall-swift $FORMAT_VERSION`
        if [ ! $? -eq 0 ]
        then
            echo $UNINSTALL_MESSAGE
            exit $?
        else
            install-swift $FORMAT_VERSION
        fi
    fi
;;
uninstall)
    ensure-env
    FORMAT_VERSION=`format-version $2`
    if [ ! $? -eq 0 ]
    then
        echo $FORMAT_VERSION
        exit 1
    else
        UNINSTALL_MESSAGE=`uninstall-swift $FORMAT_VERSION`
        if [ ! $? -eq 0 ]
        then
            echo $UNINSTALL_MESSAGE
            exit $?
        else
            echo "Successfully uninstalled Swift $FORMAT_VERSION. "
        fi
    fi
;;
attach)
    FORMAT_VERSION=`format-version $2`
    if [ ! $? -eq 0 ]
    then
        echo $FORMAT_VERSION
        exit 1
    else
        attach-version $FORMAT_VERSION
    fi
;;
clean)
    ensure-env
    rm -rf $WORKING_DIR/temp/*
;;
detach)
    rm -f $WORKING_DIR/.swift-version
;;
version)
    echo $SWIFTENV_VERSION
;;
update)
    bash < `wget -q -O- "https://raw.githubusercontent.com/stevapple/swiftenv/blob/master/install.sh"`
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