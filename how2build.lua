--[[
    Need Mac OSX and LuaJIT.
    LuaJIT can be installed from homebrew.

    download aite: https://github.com/rweichler/aite
    cd into this directory and run this command:
    /PATH/TO/AITE/main.lua

    if this errored at you in any way, email me at rweichler@gmail.com so i can fix it.

    OPTIONAL:
        install aite permanently by running this command:
        ln -s /PATH/TO/AITE/main.lua /usr/local/bin/aite

        now, instead of all those annoying steps, you'd just run this command:
        aite
]]

debber.packageinfo = {
    Package = 'com.r333d.cylinder',
    Name = 'Cylinder',
    Version = '1.0.6',
    Architecture = 'iphoneos-arm',
    Depends = 'firmware (>= 3.0), mobilesubstrate (>= 0.9.6011), preferenceloader',
    Icon = 'file:///Library/PreferenceBundles/CylinderSettings.bundle/Icon@2x.png',
    Depiction = 'http://moreinfo.thebigboss.org/moreinfo/depiction.php?file=cylinderDp',
    Description = 'Make your icons dance',
    Homepage = 'http://github.com/rweichler/cylinder',
    Maintainer = 'Reed Weichler <rweichler+cydia@gmail.com>',
    Author = 'Reed Weichler (rweichler) <rweichler+cydia@gmail.com>',
    Section = 'Tweaks',
}
debber.input = 'layout'
debber.output = 'cylinder.deb'


builder.compiler = 'gcc'
builder.build_dir = 'build'
builder.sdk = 'iphoneos'
builder.archs = {
    'armv7',
    'arm64',
}
builder.include_dirs = {
    'deps/include',
    'deps/src',
    '.tmp/include',
}
builder.library_dirs = {
    'deps/lib',
}
builder.sflags = '-mios-version-min=4.0'
builder = builder('apple')

function default(flag)
    internal.logos()
    c.lua52()
    objc.tweak()
    objc.settings()
    cydia()
end

function clean()
    os.pexecute('rm -rf src/tweak/tweak.x.o.m '..builder.build_dir..' '..debber.input..' '..debber.output)
end

function finish()
    internal.logos('clean')
end

src = {}
internal = {}
c = {}
objc = {}

local OBJECTS = {}

function cydia()
    local msdir = 'layout/Library/MobileSubstrate/DynamicLibraries'
    fs.mkdir(msdir)
    os.pexecute('cp build/Cylinder.dylib '..msdir)
    os.pexecute('cp res/Cylinder.plist '..msdir)

    fs.mkdir('layout/DEBIAN')
    os.pexecute('cp src/DEBIAN/postinst layout/DEBIAN')

    local scriptsdir = 'layout/Library/Cylinder'
    fs.mkdir(scriptsdir)
    os.pexecute('cp -r src/scripts/* '..scriptsdir)

    local prefsdir = 'layout/Library/PreferenceBundles/CylinderSettings.bundle'
    fs.mkdir(prefsdir)
    os.pexecute('cp -r res/settings/* '..prefsdir)
    os.pexecute('cp build/CylinderSettings.dylib '..prefsdir..'/CylinderSettings')
    local prefloaderdir = 'layout/Library/PreferenceLoader/Preferences'
    fs.mkdir(prefloaderdir)
    os.pexecute('cp res/CylinderSettingsLoader.plist '..prefloaderdir)
    debber():make_deb()
end

function c.lua52()
    local b = builder()
    b.src = fs.scandir('deps/src/lua/*.c')
    b.defines = {
        'LUA_USE_MACOSX',
    }
    b.output = ''
    LUA_OBJS = b:compile()
end
_G['lua5.2'] = lua52

function objc.tweak()
    -- todo: get rid of logos. using it was a bad idea
    os.pexecute('aite/bin/logos.pl src/tweak/tweak.x > src/tweak/tweak.x.o.m')

    local b = builder()
    b.src = fs.scandir('src/tweak/*.m')
    b.frameworks = {
        'UIKit',
        'Foundation',
        'QuartzCore',
        'CoreGraphics',
    }
    b.libraries = {
        'substrate',
    }
    b.bin = 'Cylinder.dylib'
    local objs = b:compile()
    b:link(table.merge(objs, LUA_OBJS))
end

function objc.settings()
    local b = builder()
    b.src = fs.scandir('src/settings/*.m')
    b.frameworks = {
        'Foundation',
        'UIKit',
        'QuartzCore',
        'CoreGraphics',
        'AVFoundation',
        --'Preferences',
    }
    b.bin = 'CylinderSettings.dylib'
    -- this is bad practice but meh
    b.ldflags = '-flat_namespace -undefined suppress'
    b:link(b:compile())
end

function internal.logos(flag)
    if flag == 'clean' then
        os.execute('rm -rf .tmp')
        return
    end

    fs.mkdir('.tmp/include/logos')
    io.open('.tmp/include/logos/logos.h', 'w'):close()
end
