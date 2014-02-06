# Cylinder

The free software alternative to Barrel

## Why?

Because I don't want to pay $2 for something that takes a few hours to make

## Todo list

* ~~Make proof-of-concept cycript 'script'~~
* ~~Port it to a Mobilesubstrate tweak~~
* Add Lua bindings
* Add preferences bundle
* Add more example Barrel thingies
* Release!

## I don't care, how do I use this shit?

### Theos

If you have theos installed on your computer, cd into substrate and make. SCP it to the phone and boom you're done.

### Cycript

If you don't want to use theos, you'll need [cycript](http://cycript.org) 0.9.5+ installed. Just copy these files in the cycript folder to your device and

```
./runme.sh
```

If that doesn't work, then do

```
cycript -p SpringBoard
```

and paste the contents in line-by-line. sorry, this is a bug with cycript :(

### WTF I just want to use this, what is this "theos" and script or whatever!??!/1!!1

idk lol

## License

[GNU GPL](https://github.com/rweichler/cylinder/blob/master/LICENSE), unless otherwise stated in the files themselves.
