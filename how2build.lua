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

local use_luajit = false -- this doesn't work (yet)
local is_beta = false

local function builder()
    local b = _G.builder('apple')
    b.compiler = 'clang'
    b.build_dir = '.aite_build'
    b.sdk_path = 'deps/iPhoneOS9.3.sdk'
    b.archs = {
        'armv7',
        'arm64',
        ffi.os == 'OSX' and 'arm64e' or nil,
    }
    b.include_dirs = {
        'deps/src',
        'deps/include',
        '.tmp/include',
    }
    if use_luajit then
        table.remove(b.include_dirs, 1)
    end
    b.library_dirs = {
        'deps/lib',
    }
    b.sflags = '-mios-version-min=4.0'
    return b
end

local deb = debber()
deb.packageinfo = {
    Package = 'com.r333d.cylinder',
    Name = 'Cylinder',
    Version = '1.1',
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
deb.input = builder().build_dir..'/layout'
deb.output = 'cylinder.deb'

do -- Append git commit hash for beta builds
    local vtail = {}
    if is_beta then
        table.insert(vtail, 'beta')
    end
    if #os.capture('git status -s') > 0 then
        table.insert(vtail, 'dirty')
    end
    if #vtail > 0 then
        table.insert(vtail, string.sub(os.capture('git rev-parse HEAD'), 1, 6))
        deb.packageinfo.Version = deb.packageinfo.Version..'~'..table.concat(vtail, '-')
    end
end

local function logos_workaround(flag)
    if flag == 'clean' then
        os.execute('rm -rf .tmp')
        return
    end

    fs.mkdir('.tmp/include/logos')
    io.open('.tmp/include/logos/logos.h', 'w'):close()
end

function default(flag)
    logos_workaround()
    tweak()
    settings()
    cydia()
end

function clean()
    os.pexecute('rm -rf '..builder().build_dir..' '..deb.output)
end

function finish()
    logos_workaround('clean')
end

function lua()
    local b = builder()
    b.src = fs.scandir('deps/src/lua/*.c')
    b.defines = {
        'LUA_USE_MACOSX',
    }
    b.output = ''
    return b:compile()
end

function cydia()
    local msdir = deb.input..'/Library/MobileSubstrate/DynamicLibraries'
    fs.mkdir(msdir)
    os.pexecute('cp '..builder().build_dir..'/Cylinder.dylib '..msdir)
    os.pexecute('cp res/Cylinder.plist '..msdir)

    fs.mkdir(deb.input..'/DEBIAN')
    os.pexecute('cp src/DEBIAN/postinst '..deb.input..'/DEBIAN')

    local scriptsdir = deb.input..'/Library/Cylinder'
    fs.mkdir(scriptsdir)
    os.pexecute('cp -r src/scripts/* '..scriptsdir)

    local prefsdir = deb.input..'/Library/PreferenceBundles/CylinderSettings.bundle'
    fs.mkdir(prefsdir)
    os.pexecute('cp -r res/settings/* '..prefsdir)
    os.pexecute('cp '..builder().build_dir..'/CylinderSettings.dylib '..prefsdir..'/CylinderSettings')
    local prefloaderdir = deb.input..'/Library/PreferenceLoader/Preferences'
    fs.mkdir(prefloaderdir)
    os.pexecute('cp res/CylinderSettingsLoader.plist '..prefloaderdir)
    deb:make_deb()
end

function tweak()
    local b = builder()

    -- todo: get rid of logos. using it was a bad idea
    os.pexecute('aite/bin/logos.pl src/tweak/tweak.x > '..fs.mkdir(b.build_dir)..'/tweak.x.o.m')

    table.insert(b.include_dirs, 'src/tweak')

    b.src = table.merge(
        fs.scandir('src/tweak/*.m'),
        b.build_dir..'/tweak.x.o.m'
    )
    b.frameworks = {
        'UIKit',
        'Foundation',
        'QuartzCore',
        'CoreGraphics',
    }
    b.libraries = {
        'substrate',
        use_luajit and 'luajit' or nil,
    }
    b.bin = 'Cylinder.dylib'
    b:link(table.merge(b:compile(), not use_luajit and lua() or nil))
end

function settings()
    local b = builder()
    b.src = fs.scandir('src/settings/*.m')
    b.frameworks = {
        'Foundation',
        'UIKit',
        'QuartzCore',
        'CoreGraphics',
        'AVFoundation',
--      'Preferences',
    }
    b.bin = 'CylinderSettings.dylib'
    b.ldflags = '-flat_namespace -undefined suppress' -- this is bad practice but meh
    b:link(b:compile())
end

function install(iphone)
    iphone = iphone or 'iphone'
    local filename = fs.split_path(deb.output)
    os.pexecute('scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null '..deb.output..' '..iphone..':')
    os.pexecute('ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null '..iphone..' "dpkg -i '..filename..'; rm '..filename..'"')
end
