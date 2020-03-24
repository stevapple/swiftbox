# swiftbox: Use Swift out of the Box on Ubuntu

![Release](https://img.shields.io/github/v/tag/stevapple/swiftbox?label=release&logo=github) ![CI Status](https://github.com/stevapple/swiftbox/workflows/CI/badge.svg)

Inspired by [pyenv](https://github.com/pyenv/pyenv) and [rbenv](https://github.com/rbenv/rbenv), while having different APIs. 

## Installation

By default, `swiftbox` will be installed at `/usr/bin`. The working directory will be set to `/opt/swiftbox` for `root` and `~/.swiftbox` for other users. 

There will be two sets of Swift environments if you use both. The local one is in favor by default unless you access `swiftbox` with `sudo`. Toolchains installed by `root` can be used by all users. 

```bash
# With wget
sh -c "$(wget -q -O- https://raw.githubusercontent.com/stevapple/swiftbox/master/install.sh)"
swiftbox version

# With curl
sh -c "$(curl -fsSL https://raw.githubusercontent.com/stevapple/swiftbox/master/install.sh)"
swiftbox version
```

Or if you'd like to use it as a script (do not support `update` yet):

```bash
# With wget
wget https://raw.githubusercontent.com/stevapple/swiftbox/master/swiftbox.sh
chmod +x swiftbox.sh
./swiftbox.sh version

# With curl
curl -o swiftbox.sh https://raw.githubusercontent.com/stevapple/swiftbox/master/install.sh
chmod +x swiftbox.sh
./swiftbox.sh version

# With git
git clone https://github.com/stevapple/swiftbox
cd swiftbox
chmod +x swiftbox.sh
./swiftbox.sh version
```

## Example Usage

### Lookup `swiftenv` version

```shell
$ swiftenv version
0.3.5
```

### Check installable Swift versions

```shell
$ swiftenv find 5.1
Version 5.1 is available for Ubuntu 18.04. 
$ swiftenv find 2.1
The Swift version does not exist or does not support your Ubuntu version. 
```

### Manage Swift versions

Currently only stable builds are available. 

```shell
$ swiftbox get 5.1
$ swiftbox remove 5.0
```

### Switch to a Swift version

```shell
$ swiftbox use 5.1
Now using Swift version 5.1. 
```

### Disable Swift

```shell
$ swiftbox disable
Swift 5.1 is now diabled. 
```

### Lookup installed Swift versions

Current version is marked with `*`. 

```shell
$ swiftbox list
- 4.2.1
- 5.1
* 5.1.5
```

### Check availability Swift versions

```shell
$ swiftbox lookup 5.1
Version 5.1 is available for Ubuntu 18.04. 
$ swiftbox lookup 2.1
The Swift version does not exist or does not support your Ubuntu version. 
```

### Lookup `swiftbox` version

```shell
$ swiftbox version
0.4
```

### Clear download cache

```shell
$ swiftbox clean
```

### Update `swiftbox`

Will install the new version to the default location, not always self-update. 

```shell
$ swiftbox update
```