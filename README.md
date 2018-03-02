# Cylinder

https://youtube.com/watch?v=Y-Pk-XDVj-o

## Build dependencies

* Mac OS X
* LuaJIT (`brew install luajit`)
* dpkg (`brew install dpkg`)

## How to build

```
git clone https://github.com/rweichler/aite
git clone https://github.com/rweichler/cylinder
cd cylinder
luajit ../aite/main.lua
```

This will create a file cylinder.deb that you can install.
