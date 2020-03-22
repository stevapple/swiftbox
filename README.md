# swiftenv: The environment manager for Swift on Ubuntu

## Installation

By default, the `root` user will install `swiftenv` at `/usr/bin`, and other users at `/usr/local/bin`. The working directory will be set to `/opt/swift` for `root` and `~/.swiftenv` for other users. 

Remember: There will be two sets of Swift environments if you use both (unrecommended). The local one will be in favor by default if you don't access it with `sudo`. 

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

### Manage Swift versions

Currently only stable builds are available. 

```shell
$ swiftenv install 5.1
$ swiftenv uninstall 5.0
$ swiftenv reinstall 5.1
```

### Attach/Detach Swift to system

```shell
$ swiftenv attach 5.1
Successfully attached Swift version 5.1. 
$ swiftenv detach
Successfully detached Swift version 5.1. 
```

### Lookup installed Swift versions

Attached version is marked with `*`. 

```shell
$ swiftenv versions
- 4.2.1
- 5.1
* 5.1.5
```

### Lookup installable Swift versions

```shell
$ swiftenv find 5.1
Version 5.1 is available for Ubuntu 18.04. 
$ swiftenv find 2.1
The Swift version does not exist or does not support your Ubuntu version. 
```

### Lookup `swiftenv` version

```shell
$ swiftenv version
0.2
```

### Clean downloaded files

```shell
$ swiftenv clean
```

### Update `swiftenv`

Will install the new version to the default location, not always self-update. 

```shell
$ swiftenv update
```