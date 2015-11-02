# Cylinder

![](https://github.com/rweichler/cylinder/raw/master/code.png)

## Latest version: 1.0.6

[Here](http://github.com/rweichler/cylinder/tree/master/CHANGELOG.md)'s the changelog.

[Here](https://github.com/rweichler/cylinder/raw/master/cylinder.deb)'s the deb.

## wat???

This is a jailbreak tweak that lets you animate your icons when you swipe pages on the SpringBoard.

Differences to Barrel:

1. Combining multiple effects
2. Effects are written in [Lua](http://lua.org/about.html)

With Lua, the effects can be modified and created using just
a text editor (scripts are stored in /Library/Cylinder). No knowledge of C or
Objective-C is necessary. A noob-friendly tutorial can be found [here](https://github.com/rweichler/cylinder/wiki/Installing-and-modifying-Lua-scripts).

Custom scripts can be submitted to [/r/cylinder](http://reddit.com/r/cylinder).

If you want to make your own effects, check out [any of the 53 scripts that are bundled with Cylinder](https://github.com/rweichler/cylinder/tree/master/tweak/scripts). If you need more in-depth documentation you can check out
[EXAMPLE.lua](https://github.com/rweichler/cylinder/blob/master/tweak/scripts/EXAMPLE.lua)
as well.
Once you've made your own effect, make a folder with
your name in /Library/Cylinder on your phone (like
/Library/Cylinder/rweichler), drop your scripts in,
and it should appear in settings (no respring required).

Compatible with iOS 4-9.

# How to build/install this

This is for people that would like to contribute to the core (C / Objective-C) framework.
If you would like to create your own scripts, no extra setup is necessary. Just install Cylinder
on Cydia and follow the instructions above.

## Dependencies

* Mac OS X, Linux or jailbroken iOS
* Perl (for Logos. This project *does not* use Theos! And Logos is included already.)
* Xcode (or, clang/make and a copy of the iPhone SDK &gt;= iOS 4)

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

### For those who don't have Xcode installed

Open `config.mk` and edit the line that says `SDK=` to reflect where your copy of the iPhone SDK is.

DHowett has been nice enough to host them for us here: http://iphone.howett.net/sdks/

Just download one of those (must be >= iOS 4, and preferably >= 7 for 64-bit support), unzip it somewhere, delete the original .tar.gz and paste wherever you unzipped it after the `SDK=` in the config.mk.

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

Pull requests here are only for changes and improvements to the core framework. Not Lua scripts.

I regularly check [/r/cylinder](http://reddit.com/r/cylinder). If I see a script there I'd like
to include by default, I'll PM you.

## License

[GPLv3](https://github.com/rweichler/cylinder/blob/master/LICENSE), unless otherwise stated in the files themselves.
