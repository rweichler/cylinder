# Cylinder

The free software alternative to Barrel

![LOL](http://i.imgur.com/JhSytf7m.png)

## Why?

Because I don't want to pay $2 for something that takes a few hours to make (plz dont hit me)

## What works

Lua bindings. Check out [lol.lua](https://github.com/rweichler/cylinder/blob/master/lol.lua) to customize the way the pages turn and stuff.

Currently the only thing you can manipulate is the page itself,
but soon you can manipulate the icons themselves too. I just need to
figure out how to implement that in a decent way.

## Todo list

* ~~Make proof-of-concept cycript 'script'~~
* ~~Port it to a Mobilesubstrate tweak~~
* ~~Add Lua bindings~~
* Add more Lua bindings
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
