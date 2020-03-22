# swiftenv: The environment manager for Swift on Ubuntu

![Release](https://img.shields.io/github/v/tag/stevapple/swiftenv?label=release&logo=github) ![CI Status](https://github.com/stevapple/swiftenv/workflows/CI/badge.svg)

Inspired by [pyenv](https://github.com/pyenv/pyenv) and [rbenv](https://github.com/rbenv/rbenv). 

## Installation

By default, `swiftenv` will be installed at `/usr/bin`. The working directory will be set to `/opt/swift` for `root` and `~/.swiftenv` for other users. 

There will be two sets of Swift environments if you use both. The local one is in favor by default unless you access `swiftenv` with `sudo`. Toolchains installed by `root` can be used by all users. 

```bash
# With wget
sh -c "$(wget -q -O- https://raw.githubusercontent.com/stevapple/swiftenv/master/install.sh)"
swiftenv version

# With curl
sh -c "$(curl -fsSL https://raw.githubusercontent.com/stevapple/swiftenv/master/install.sh)"
swiftenv version
```

Or if you'd like to use it as a script (do not support `update` yet):

```bash
# With wget
wget https://raw.githubusercontent.com/stevapple/swiftenv/master/swiftenv.sh
chmod +x swiftenv.sh
./swiftenv.sh version

# With curl
curl -o swiftenv.sh https://raw.githubusercontent.com/stevapple/swiftenv/master/install.sh
chmod +x swiftenv.sh
./swiftenv.sh version

# With git
git clone https://github.com/stevapple/swiftenv
cd swiftenv
chmod +x swiftenv.sh
./swiftenv.sh version
```

## Example Usage

### Lookup `swiftenv` version

```shell
$ swiftenv version
0.3.5
```

### Lookup installable Swift versions

```shell
$ swiftenv find 5.1
Version 5.1 is available for Ubuntu 18.04. 
$ swiftenv find 2.1
The Swift version does not exist or does not support your Ubuntu version. 
```

### Manage Swift versions

Currently only stable builds are available. 

```shell
$ swiftenv install 5.1
$ swiftenv uninstall 5.0
$ swiftenv reinstall 5.1
```

### Lookup installed Swift versions

The attached version is marked with `*`. 

```shell
$ swiftenv versions
- 4.2.1
- 5.1
* 5.1.5
```

### Attach/Detach Swift to system

```shell
$ swiftenv attach 5.1
Successfully attached Swift version 5.1. 
$ swiftenv detach
Successfully detached Swift version 5.1. 
```

### Clear download cache

```shell
$ swiftenv clean
```

### Update `swiftenv` (Unstable)

Will install the new version to the default location, not always self-update. 

```shell
$ swiftenv update
```