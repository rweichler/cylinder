# Cylinder

The free software alternative to Barrel

![](https://raw2.github.com/rweichler/cylinder/master/screenie.gif)

## Why?

Because I don't want to pay $2 for something that takes a few ~~hours~~ days to make (plz dont hit me)

## What works

Currently this *CAN* do everything Barrel does, you can
manipulate the individual icons and the page using Lua.
However that doesn't mean that all of Barrel's animations
are here. The only ones I have coded so far are the cube
inside, cube outside, and the icon roll. It's really
easy to add your own effects, though. Check out
[EXAMPLE.lua](https://github.com/rweichler/cylinder/blob/master/tweak/scripts/EXAMPLE.lua).


## Supported devices / iOS versions

* iPod touch 4
* iOS 5.1.1
* iPhone 4S
* iOS 7.0.4

I have this compiled for arm64, so this *should* work on a 5S. But idk. Someone let me know!

## Todo list

* ~~Make proof-of-concept cycript 'script'~~
* ~~Port it to a Mobilesubstrate tweak~~
* ~~Add Lua bindings~~
* ~~Add preferences bundle~~
* Add more example Barrel thingies
* Code cleanup
* Release!

##Building

### The tweak itself

```
cd tweak
make
export MOBSUB=/Library/MobileSubstrate/DynamicLibraries/
scp Cylinder.dylib iphone:$MOBSUB
scp Cylinder.plist iphone:$MOBSUB
scp -r scripts/* iphone:/Library/Cylinder/
```

* "iphone" is root@192.168.1.x or whatever your iphone's IP address is.
* /Library/Cylinder must be a folder on the phone.

### The preference bundle

NOTE: You need rpetrich's [theos](http://github.com/rpetrich/theos) installed.

You also need a working copy of ldid ([instructions here](http://iphonedevwiki.net/index.php/Theos/Getting_Started#On_Mac_OS_X_or_Linux)),
and you need the "theos" alias in the settings directory to
point to wherever you installed theos.

```
cd settings
make
```

Then, you need to copy it to your phone with SCP. Check out the "copy" file
in that directory and edit it for your setup. Then just run

```
./copy
```

## License

[GNU GPL](https://github.com/rweichler/cylinder/blob/master/LICENSE), unless otherwise stated in the files themselves.

________

Also it's kind of funny, I wanted to pick a name that was like Barrel, and I landed on Cylinder. I didn't even realize the significance of the 'Cy' prefix. hehehehehhehehehe. Sorry saurik.
