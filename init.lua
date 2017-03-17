jit.off()

local PATH = '/var/lua/jjjj.app'
package.path = PATH..'/?.lua;'..
               PATH..'/?/init.lua;'..
               package.path

objc = require 'objc'
ffi = require 'ffi'
C = ffi.C

ffi.cdef[[
void MSHookMessageEx(Class class, SEL message, void *hook, void *old);
void lucy_syslog(const char *);
]]

local lib  = ffi.load('/var/root/syslog.dylib', true)
function print(s)
    lib.lucy_syslog(tostring(s))
end

local function hook(class, sel, ct, f)
    local orig = ffi.new(ct)
    local k = ffi.new(ct, function(...)
        return f(orig[0], ...)
    end)
    C.MSHookMessageEx(class, sel, k[0], orig)
end

hook(objc.SBRootFolderView, objc.SEL('scrollViewDidScroll:'), 'void (*[1])(id, SEL, id)', function(orig, self, _cmd, scrollView)
    orig(self, _cmd, scrollView)
    if not FAILED then
        local success, err = pcall(scrol, scrollView)
        if not success then
            FAILED = true
            print(err)
        end
    end
end)

dofile('/var/root/tmp/cylinder.lua')
