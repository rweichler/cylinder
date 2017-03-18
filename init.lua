jit.off()
local USE_C = true -- change this

PATH = '/var/root/test'
package.path = PATH..'/?.lua;'..
               PATH..'/?/init.lua;'..
               package.path
package.cpath = PATH..'/?.so;'..
                package.cpath

objc = require 'objc'
ffi = require 'ffi'
C = ffi.C

ffi.cdef[[
void MSHookMessageEx(Class class, SEL message, void *hook, void *orig);
]]

if USE_C then
    local id = ffi.typeof('id')
    function LMFAO(scrollView) -- this is called from the c lib
        scrol(id(scrollView))
    end
    require 'hook' -- c lib that calls MSHookMessageEx
else
    local orig = ffi.new('void (*[1])(id, SEL, id)')
    -- this is the function that corrupts the memory somehow
    local hook = function(self, _cmd, scrollView)
        orig[0](self, _cmd, scrollView)
        scrol(scrollView)
    end
    C.MSHookMessageEx(objc.SBRootFolderView or objc.SBIconController, objc.SEL('scrollViewDidScroll:'), ffi.cast('void (*)(id, SEL, id)', hook), orig)
end

require 'cylinder'
