# swiftbox: Use Swift out of the Box on Ubuntu, CentOS(RHEL) and Amazon Linux

![Release](https://img.shields.io/github/v/release/stevapple/swiftbox?logo=github) ![CI Status](https://github.com/stevapple/swiftbox/workflows/CI/badge.svg)

Inspired by [pyenv](https://github.com/pyenv/pyenv) and [rbenv](https://github.com/rbenv/rbenv), and having different APIs.

## Installation

By default, `swiftbox` will be installed at `/usr/bin`. The working directory will be set to `/opt/swiftbox` for `root` and `~/.swiftbox` for other users.

There will be two sets of Swift environments if you use both. The local one is in favor by default unless you access `swiftbox` with `sudo`. Toolchains installed by `root` can be used by all users.

```bash
# With curl (Recommended)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/stevapple/swiftbox/master/install.sh)"
swiftbox -v

# With git
git clone https://github.com/stevapple/swiftbox && cd swiftbox
chmod +x install.sh
./install.sh
```

Or if you'd like to use it as a script (doesn't support `update` yet):

```bash
# With wget
wget https://raw.githubusercontent.com/stevapple/swiftbox/master/swiftbox.sh
chmod +x swiftbox.sh
./swiftbox.sh -v

# With curl
curl -o swiftbox.sh https://raw.githubusercontent.com/stevapple/swiftbox/master/swiftbox.sh
chmod +x swiftbox.sh
./swiftbox.sh -v

# With git
git clone https://github.com/stevapple/swiftbox && cd swiftbox
chmod +x swiftbox.sh
./swiftbox.sh -v
```

You can specify release version by using jsDelivr or git, which also has wider availability:

```bash
# With wget
wget https://cdn.jsdelivr.net/gh/stevapple/swiftbox@0.10/swiftbox.sh
chmod +x swiftbox.sh
./swiftbox.sh -v

# With curl
curl -o swiftbox.sh https://cdn.jsdelivr.net/gh/stevapple/swiftbox@0.10/swiftbox.sh
chmod +x swiftbox.sh
./swiftbox.sh -v

# With git
git clone https://github.com/stevapple/swiftbox && cd swiftbox
git checkout v0.10
chmod +x swiftbox.sh
./swiftbox.sh -v
```

You can later install it to `/usr/bin`:

```console
$ sudo ./swiftbox.sh install
Successfully installed swiftbox at /usr/bin
$ which swiftbox
/usr/bin/swiftbox
```

## Example Usage

You may notice a `[user]` or `[global]` prefix in the output, which indicates the scope of swiftbox operations and Swift versions.

### Show `swiftbox` version

```console
$ swiftbox -v
0.9
```

### Check the availability of Swift versions

```console
$ swiftbox lookup 5.2.4
[global] Swift 5.2.4 is kept locally and set to default.
$ swiftbox lookup 5.1
Swift 5.1 is available for Ubuntu 18.04, you can get it with: swiftbox get 5.1
$ swiftbox lookup nightly
Swift nightly build 2020-05-11-a is available for Amazon Linux 2, you can get it with: swiftbox get nightly
$ swiftbox lookup 2.1
Swift 2.1 does not exist or does not support your CentOS Linux version.
```

### Manage Swift versions

Both release builds and the latest nightly build are available.

```console
$ swiftbox get 5.2.2
$ swiftbox get nightly
$ swiftbox remove 5.0
```

### Switch to a Swift version

```console
$ swiftbox use 5.2.2
[user] Now using Swift 5.2.2
```

### Disable Swift

```console
$ sudo swiftbox close
[global] Swift 5.2.2 is now disabled.
```

### Lookup installed Swift versions

The active one is marked with `*`.

```console
$ swiftbox list
- 2020-05-10-a
- 4.2.1
* 5.2.2
```

### Clear download cache

```console
$ swiftbox clean
[user] Successfully cleaned the cache.
```

### Update `swiftbox`

Update to the latest version if `swiftbox` is installed in `/usr/bin`.

```console
$ swiftbox update
Successfully upgraded swiftbox from 0.9 to 0.10.6
```
