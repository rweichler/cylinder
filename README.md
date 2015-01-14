# Cylinder

![](https://github.com/rweichler/cylinder/raw/master/code.png)

## Latest version: 1.0.2

[Here](http://github.com/rweichler/cylinder/tree/master/CHANGELOG.md)'s the changelog.

[Here](https://github.com/rweichler/cylinder/raw/master/cylinder.deb)'s the deb.

## wat???

This is a jailbreak tweak that lets you animate your icons when you swipe pages on the SpringBoard.

The kicker about this one is two things:

1. Combining multiple effects
2. Effects are written in [Lua](http://lua.org/about.html)

This allows for unprecedented flexibility. Users do not have to depend on the developer
to add new icon effects, as they can just code them in Lua with a simple text editor
and copy to them to the phone. The existing scripts can also serve to help newbies start making their own scripts if they so desire.

If you want more, check out [/r/cylinder](http://reddit.com/r/cylinder)!

If you want to make your own effects, check out [any of the 53 scripts that are bundled with Cylinder](https://github.com/rweichler/cylinder/tree/master/tweak/scripts). If you need more in-depth documentation you can check out
[EXAMPLE.lua](https://github.com/rweichler/cylinder/blob/master/tweak/scripts/EXAMPLE.lua)
as well.
Once you've made your own effect, make a folder with
your name in /Library/Cylinder on your phone (like 
/Library/Cylinder/rweichler), drop your scripts in,
and it should appear in settings. You don't even have to
respring! This allows for rapid testing.

## Compatible iOS versions

### Tested

* iOS 4
* iOS 5
* iOS 6
* iOS 7
* iOS 8

### Not tested, but might work

* iPhone OS 3

### Probably doesn't work

* iPhone OS 2
* iPhone OS

I'm probably never going to support these because a device that can run iOS 1 can run iOS 3.

##.deb files

If you don't feel like building this, [here's a .deb of the latest stable build](http://r333d.com/repo/cylinder.php).

And... [here's a deb of the latest **UNSTABLE** build](http://r333d.com/repo/cylinder.php?unstable=1).

## Setup

First, clone the repository and cd into it

```
git clone https://github.com/rweichler/cylinder.git
cd cylinder
```

Then, init the submodules:

```
git submodule update --init
```

### Then, modify the Makefiles to reflect where you have your iPhone SDK.

Open `settings/Makefile` and `tweak/Makefile` and edit the line that says `SDK_PATH=` to reflect where your copy of the iPhone SDK is (explained later).

### Where to get the iPhone SDK

#### If you have Xcode installed

You already have it!

You can find it by running the command:

```
echo "$(xcode-select --print-path)/Platforms/iPhoneOS.platform/Developer/SDKs/"
```

All of your copies of the iPhone SDK are in that directory. So for example, if `xcode-select --print-path` outputs `/Applications/Xcode.app/Contents/Developer` and you have `iPhoneOS5.1.sdk` in that directory, you'd put `SDK_PATH=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.1.sdk` in the two different Makefiles.

#### If you don't have Xcode or if you're building directly on-device instead of on a Mac

DHowett has been nice enough to host them for us here: http://iphone.howett.net/sdks/

Just download one of those (must be higher than iOS 3, and preferably higher than 7 for 64-bit support), unzip it somewhere, delete the original .tar.gz and paste wherever you unzipped it after the `SDK_PATH=` in the makefile.


## Building

If you just want a .deb, run this:

```
make package
```

If you want it to install on your device, run this:
```
make install IPHONE_IP=iphone_wifi_ip_here
```
You need OpenSSH installed in order for the installation to work.

## Pull request policy

Pull requests are only for changes and improvements to the core framework. Not custom Lua scripts.

Feel free to post them to [/r/cylinder](http://reddit.com/r/cylinder). Once this is on BigBoss there will also be an easy way for you to submit your scripts there too.

## License

[GNU GPL](https://github.com/rweichler/cylinder/blob/master/LICENSE), unless otherwise stated in the files themselves.
