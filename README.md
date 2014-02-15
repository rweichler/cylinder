# TO PEOPLE WHO JUST WANT A .DEB

### *ESPECIALLY* insanelyi and hackyouriphone

[USE THIS ONE!!!!!](http://r333d.com/repo/cylinder.php) THE ONE IN THIS REPOSITORY IS AN **_UNSTABLE BUILD_**. It's literally broken.


# Cylinder

The free software alternative to Barrel

![](https://raw2.github.com/rweichler/cylinder/master/code.png)

## Why?

Because.

## What works

Everything!

## Available Effects

* Cube (inside)
* Cube (outside)
* Stairs (down left)
* Stairs (down right)
* [Spin](https://raw2.github.com/rweichler/cylinder/master/screenie.gif)
* Chomp &lt;---- custom "chomping" effect I made
* And [*dozens*](http://www.youtube.com/watch?v=lKie-vgUGdI) of tweaks on [/r/cylinder](http://reddit.com/r/cylinder)!

If you want to make your own effects, check out
[EXAMPLE.lua](https://github.com/rweichler/cylinder/blob/master/tweak/scripts/EXAMPLE.lua).
Once you've made your own effect, just drop it in
/Library/Cylinder on your phone, and it should
appear in settings. You don't even have to respring!
This allows for rapid testing.


## Compatible devices

### Tested

* iPod touch 4
* iPod touch 5
* iPhone 4S
* iPhone 5S

## Compatible iOS versions

### Tested

* iOS 5
* iOS 7

### Not tested, but almost definitely works

* iOS 6
* iOS 4

### Not tested, but might work

* iOS 3

### Probably doesn't work

* iOS 2
* iPhone OS

## Todo list

* ~~Make proof-of-concept cycript 'script'~~
* ~~Port it to a Mobilesubstrate tweak~~
* ~~Add Lua bindings~~
* ~~Add preferences bundle~~
* ~~Fix OS specific bugs~~ &lt;----- well, maybe not all of them but it is acceptable
* ~~Add randomize switch~~
* Add more example Barrel thingies
* Code cleanup

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

## License

[GNU GPL](https://github.com/rweichler/cylinder/blob/master/LICENSE), unless otherwise stated in the files themselves.
