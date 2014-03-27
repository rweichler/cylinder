# Cylinder

![](https://raw2.github.com/rweichler/cylinder/master/code.png)

## Latest version: 0.14.3.16

[Here](http://github.com/rweichler/cylinder/tree/master/CHANGELOG.md)'s the changelog.

[Here](https://github.com/rweichler/cylinder/raw/master/cylinder.deb)'s the deb.

## What!?!?!?!??!

This lets you animate your icons when you swipe pages on the SpringBoard.

The kicker about this one is two things:

1. Combining multiple effects
2. Effects are written in [Lua](http://lua.org/about.html)

This allows for unprecedented flexibility. Users do not have to depend on the developer
to add new icon effects, as they can just code them in Lua with a simple text editor
and copy to them to the phone. The existing scripts can also serve to help newbies start making their own scripts if they so desire.

If you want more, check out [/r/cylinder](http://reddit.com/r/cylinder)!

If you want to make your own effects, check out [any of the 45 scripts that are bundled with Cylinder](https://github.com/rweichler/cylinder/tree/master/tweak/scripts). If you need more in-depth documentation you can check out
[EXAMPLE.lua](https://github.com/rweichler/cylinder/blob/master/tweak/scripts/EXAMPLE.lua)
as well.
Once you've made your own effect, make a folder with
your name in /Library/Cylinder on your phone (like 
/Library/Cylinder/rweichler), drop your scripts in,
and it should appear in settings. You don't even have to
respring! This allows for rapid testing.

## Compatible iOS versions

### Tested

* iOS 4 (preference bundle crashes)
* iOS 5
* iOS 6
* iOS 7

### Not tested, but might work

* iOS 3

### Probably doesn't work

* iOS 2
* The first iOS

I'm probably never going to support these because a device that can run iOS 1 can run iOS 3.

##Building

If you don't feel like building this, [here's a .deb of the latest stable build](http://r333d.com/repo/cylinder.php).

First, init the submodules:

```
git submodule update --init
```

And then make:

```
make package
```

Puts a freshly baked cylinder.deb in the root of the repository. :)

## Pull request policy

Pull requests are only for changes and improvements to the core framework. Not custom Lua scripts.

Feel free to post them to [/r/cylinder](http://reddit.com/r/cylinder). Once this is on BigBoss there will also be an easy way for you to submit your scripts there too.

## License

[GNU GPL](https://github.com/rweichler/cylinder/blob/master/LICENSE), unless otherwise stated in the files themselves.
