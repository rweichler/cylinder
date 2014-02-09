# Cylinder

The free software alternative to Barrel

![](https://raw2.github.com/rweichler/cylinder/master/screenie.gif)

## Why?

Because.

## What works

Currently this *CAN* do everything Barrel does, you can
manipulate the individual icons and the page using Lua.
However that doesn't mean that all of Barrel's animations
are here. The only ones I have coded so far are the cube
inside, cube outside, and the icon roll. It's really
easy to add your own effects, though. Check out
[EXAMPLE.lua](https://github.com/rweichler/cylinder/blob/master/tweak/scripts/EXAMPLE.lua).


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
* Release!

I'd really appreciate it if nobody posted this on reddit,
or jailbreakqa or anything like that until I get to the
Release step. This tweak is unstable, and a lot of bindings
are temporary, and if this gets publicized before I finish
it will be hard to update. Thanks!

##Building

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

________

Also it's kind of funny, I wanted to pick a name that was like Barrel, and I landed on Cylinder. I didn't even realize the significance of the 'Cy' prefix. hehehehehhehehehe. Sorry saurik.
