# Cylinder

The free software alternative to Barrel

![LOL](http://i.imgur.com/JhSytf7m.png)

## Why?

Because I don't want to pay $2 for something that takes a few hours to make (plz dont hit me)

## What works

Lua bindings. Check out [lol.lua](https://github.com/rweichler/cylinder/blob/master/lol.lua) to customize the way the pages turn and stuff.

Currently this *CAN* do everything Barrel does, you can
manipulate the individual icons and the page using Lua.
However that doesn't mean that all of Barrel's animations
are here. The only ones I have coded so far are the cube
inside, cube outside, and the icon roll.

Currently there isn't a binding to set the alpha of the icons, but I'm working on that.

There are some performance problems with manipulating the icons (just manipulating the page is fine). I'm going to investigate that soon.

## Todo list

* ~~Make proof-of-concept cycript 'script'~~
* ~~Port it to a Mobilesubstrate tweak~~
* ~~Add Lua bindings~~
* Add preferences bundle
* Add more example Barrel thingies
* Code cleanup
* Release!

##Building

```
make
export MOBSUB=/Library/MobileSubstrate/DynamicLibraries/
scp Cylinder.dylib iphone:$MOBSUB
scp Cylinder.plist iphone:$MOBSUB
scp lol.lua iphone:/Library/Cylinder/
```

"iphone" is root@192.168.1.x or whatever your iphone's IP address is.
/Library/Cylinder must be a folder on the phone.

## License

[GNU GPL](https://github.com/rweichler/cylinder/blob/master/LICENSE), unless otherwise stated in the files themselves.
