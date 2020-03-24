# swiftbox: Use Swift out of the Box on Ubuntu

![Release](https://img.shields.io/github/v/tag/stevapple/swiftbox?label=release&logo=github) ![CI Status](https://github.com/stevapple/swiftbox/workflows/CI/badge.svg)

Inspired by [pyenv](https://github.com/pyenv/pyenv) and [rbenv](https://github.com/rbenv/rbenv), and having different APIs. 

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

You can later install it to `/usr/bin`:

```shell
$ ./swiftbox.sh install
Successfully installed swiftbox to system.
$ which swiftbox
/usr/bin/swiftbox
```

## Example Usage

### Lookup `swiftbox` version

```shell
$ swiftbox version
0.4.2
```

### Check the availability of Swift versions

```shell
$ swiftbox lookup 5.1
Swift 5.1 is available for Ubuntu 18.04. 
$ swiftbox lookup 2.1
Swift 2.1 does not exist or does not support your Ubuntu version. 
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
Now using Swift 5.1. 
```

### Disable Swift

```shell
$ swiftbox disable
Swift 5.1 is now disabled. 
```

### Lookup installed Swift versions

The active one is marked with `*`. 

```shell
$ swiftbox list
- 4.2.1
- 5.1
* 5.1.5
```

### Clear download cache

```shell
$ swiftbox clean
```

### Update `swiftbox`

Update to the latest version if `swiftbox` is installed in `/usr/bin`. 

```shell
$ swiftbox update
```