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

If you encounter network error, you may consider using jsDelivr:

```bash
# Auto installation
sh -c "$(curl -fsSL https://cdn.jsdelivr.net/gh/stevapple/swiftbox@latest/install.sh)"
swiftbox -v

# Manual installation
sudo curl -o /usr/bin/swiftbox https://cdn.jsdelivr.net/gh/stevapple/swiftbox@latest/swiftbox.sh
sudo chmod +x /usr/bin/swiftbox
swiftbox -v
```

Or if you'd like to use it as a script:

```bash
# With wget
wget https://raw.githubusercontent.com/stevapple/swiftbox/master/swiftbox.sh
chmod +x swiftbox.sh
./swiftbox.sh -v
```

You can specify release version by using jsDelivr or git:

```bash
# With wget
wget https://cdn.jsdelivr.net/gh/stevapple/swiftbox@0.12.2/swiftbox.sh
chmod +x swiftbox.sh
./swiftbox.sh -v

# With git
git clone https://github.com/stevapple/swiftbox && cd swiftbox
git checkout v0.12.2
chmod +x swiftbox.sh
./swiftbox.sh -v
```

You can later install it to system by copying it to any directory in `PATH`:

```console
$ sudo cp swiftbox.sh /usr/bin/swiftbox
$ which swiftbox
/usr/bin/swiftbox
```

## Basic Usage

You may notice a `[user]` or `[global]` prefix in the output, which indicates the scope of swiftbox operations and Swift versions.

### Show `swiftbox` version

Both `swiftbox` amd system (or alias) version will be shown with `-v` or `--version`. Add `-s` or `--short` to omit system version.

```console
$ swiftbox --version
0.12.3 (Ubuntu 20.04)
$ swiftbox -v -s
0.12.3
```

### Check the availability of Swift versions

```console
$ swiftbox check 5.2.4
[global] Swift 5.2.4 is kept locally and set to default.
$ swiftbox check 5.1
Swift 5.1 is available for Ubuntu 18.04
You can get it with: swiftbox get 5.1
$ swiftbox check nightly
Swift nightly build 2020-05-11-a is available for Amazon Linux 2
You can get it with: swiftbox get nightly
$ swiftbox check 2.1
Swift 2.1 does not exist or does not support your CentOS Linux version.
```

### Manage Swift toolchains

Both release builds and the latest nightly build are available.

```console
$ swiftbox get 5.2.2
$ swiftbox get nightly
$ swiftbox remove 5.0
```

### Select a Swift version

```console
$ swiftbox use 5.2.2
[user] Now using Swift 5.2.2
```

### Disable Swift

```console
$ sudo swiftbox close
[global] Swift 5.2.2 is now disabled.
```

### List local toolchain versions

The active one is marked with `*`. System versions will also be shown, and you can use `-s` or `--short` to omit. 

```console
$ swiftbox list
- 2020-05-10-a (Ubuntu 20.04)
- 4.2.1 (Ubuntu 18.04)
* 5.2.2 (Ubuntu 20.04)
$ sudo swiftbox list -s
- 2020-04-03-a
- 4.3
```

### Clear download cache

```console
$ swiftbox cleanup
[user] Successfully cleaned the cache.
```

### Upgrade `swiftbox`

Upgrade the current copy of `swiftbox` to the latest version.

```console
$ swiftbox upgrade
Successfully upgraded swiftbox from 0.12 to 0.12.2
```

### Show help page

```console
$ swiftbox -h
```

And you'll see an output as follow:
```
swiftbox: Use Swift out of the Box on Ubuntu, CentOS(RHEL) and Amazon Linux

Usage: swiftbox [option]
       swiftbox [command] ...

Options:
  -v                        Show swiftbox version
  -h                        Show help page

Commands:
  check <version>           Check the availability of Swift <version>
        nightly             Check the availability of Swift nightly builds
  get <version>             Get Swift <version> from swift.org
      nightly               Get the latest nightly build from swift.org
  list                      List Swift versions on the computer
  use <version>             Select Swift <version> as default
  remove <version>          Remove swift <version> from the computer
  close                     Disable Swift managed by swiftbox
  cleanup                   Clear swiftbox download cache
  upgrade                   Upgrade swiftbox to the latest version
```

## Advanced Usage

### Alias your system version in `swiftbox`

Since Ubuntu has non-LTS versions and they may be (partially) compatible with toolchains built for LTS versions, `swiftbox` allows aliases (See #1) by specifying the version in `.system-alias` file in its working directory.

```console
$ swiftbox -v
0.12.3 (Ubuntu 19.10)
$ echo "20.04" > ~/.swiftbox/.system-alias
$ swiftbox -v
0.12.3 (Ubuntu 20.04)
$ swiftbox check 5.2.4
Swift 5.2.4 is available for Ubuntu 20.04
You can get it with: swiftbox get 5.2.4
```

## Known issues with upgrading

### Version < 0.11

Users of these versions should do a fresh installation for the upgrade.

You can use one of the following ways:

```console
$ swiftbox update
swiftbox 0.9 is already installed in /usr/bin
Input 'yes' or 'y' to upgrade, anything else to do a fresh installation: n
```

```console
$ sudo rm /usr/bin/swiftbox
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/stevapple/swiftbox/master/install.sh)"
```

```console
$ sudo curl -o /usr/bin/swiftbox https://cdn.jsdelivr.net/gh/stevapple/swiftbox@0.12.2/swiftbox.sh
$ sudo chmod +x /usr/bin/swiftbox
$ swiftbox upgrade
```

### Version = 0.11 | 0.11.1

Users of these versions should do a fresh installation for the upgrade.

You can use one of the following ways:

```console
$ swiftbox upgrade
swiftbox 0.11.1 is already installed in /usr/bin
Input 'yes' or 'y' to upgrade, anything else to do a fresh installation: n
```

```console
$ sudo rm /usr/bin/swiftbox
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/stevapple/swiftbox/master/install.sh)"
```

```console
$ sudo curl -o /usr/bin/swiftbox https://cdn.jsdelivr.net/gh/stevapple/swiftbox@0.12.2/swiftbox.sh
$ sudo chmod +x /usr/bin/swiftbox
$ swiftbox upgrade
```

### Version = 0.12 | 0.12.1

Users of these versions should upgrade manually or with `sudo` if the installation path belongs to `root`.

You can use one of the following ways:

```console
$ sudo swiftbox upgrade
```

```console
$ sudo curl -o /usr/bin/swiftbox https://cdn.jsdelivr.net/gh/stevapple/swiftbox@0.12.2/swiftbox.sh
$ sudo chmod +x /usr/bin/swiftbox
$ swiftbox upgrade
```