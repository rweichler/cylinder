# Cylinder

The free software alternative to Barrel

![](https://raw2.github.com/rweichler/cylinder/master/screenie.gif)

## Why?

Because.

## What works

Everything!

## Available Effects

* Cube (inside)
* Cube (outside)
* Stairs (down left)
* Stairs (down right)
* Spin &lt;---- the one in the screenshot
* Chomp &lt;---- custom "chomping" effect I made

If you want to make your own effects, check out
[EXAMPLE.lua](https://github.com/rweichler/cylinder/blob/master/tweak/scripts/EXAMPLE.lua).
Once you've made your own effect, just drop it in
/Library/Cylinder on your phone, and it should
appear in settings. You don't even have to respring!
This allows for rapid testing.


## Tested devices / iOS versions

* iPod touch 4 on 5.1.1 (no preference menu)
* iPhone 4S on 7.0.4
* iPhone 5S on 7.0.4 (no preference menu)

## Todo list

* ~~Make proof-of-concept cycript 'script'~~
* ~~Port it to a Mobilesubstrate tweak~~
* ~~Add Lua bindings~~
* ~~Add preferences bundle~~
* Add more example Barrel thingies
* Code cleanup
* Release?

I'd really appreciate it if nobody posted this on reddit,
or jailbreakqa or anything like that until I get to the
Release step. This tweak is unstable, and a lot of bindings
are temporary, and if this gets publicized before I finish
it will be hard to update. Thanks!

##Building

If you don't feel like building this, [here's a .deb](https://raw2.github.com/rweichler/cylinder/master/cylinder.deb).

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
