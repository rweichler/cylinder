# Cylinder

The free software alternative to Barrel

![LOL](http://i.imgur.com/JhSytf7m.png)

## Why?

Because I don't want to pay $2 for something that takes a few hours to make

## Todo list

* ~~Make proof-of-concept cycript 'script'~~
* ~~Port it to a Mobilesubstrate tweak~~
* Add Lua bindings
* Add preferences bundle
* Add more example Barrel thingies
* Release!

##Building

```
make
export MOBSUB=/Library/MobileSubstrate/DynamicLibraries/
scp Cylinder.dylib iphone:$MOBSUB
scp Cylinder.plist iphone:$MOBSUB
```

## License

[GNU GPL](https://github.com/rweichler/cylinder/blob/master/LICENSE), unless otherwise stated in the files themselves.
