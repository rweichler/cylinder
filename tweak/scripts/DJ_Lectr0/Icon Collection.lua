PI = 3.14159265

function abs(x) --> absolute value convenience function
    if x < 0 then
        return -x
    else
        return x
    end
end

--this is the function that gets called when the screen moves
--remember to "return" it at the end
--"view" is the icon page you will be manipulating (aka a view)
--"offset" is the x-offset of the current page to the center of the screen
--"width" and "height" are the width and height of the screen

return function(view, offset, width, height)
    local percent = offset/width

   local percent2 = abs(percent)

                            


    local i = 0
    while true do --> loop through all of the icons
        i = i + 1
        local icon = view[i]
        if icon == nil then --> if there is no view
            break --break out of the loop
        else
local perf = 1.08
              local mult = -1
        if i <= 4 then mult = 1 end
if i > 4 then mult = 0.5 end
if i >8 then mult = 0 end
if i > 12 then mult = -0.5 end
if i > 16 then mult = -1 end
        
local mult2 = 0
if percent >= 0 then
        if (i+3)%4==0  then mult2 = 1.3 end
if (i+2)%4==0  then mult2 = 0.8 end
if (i+1)%4==0  then mult2 = 0.3 end
if (i+0)%4==0  then mult2 = -0.2 end

        

else
if (i+3)%4==0  then mult2 = -0.2 end
if (i+2)%4==0  then mult2 = 0.3 end
if (i+1)%4==0  then mult2 = 0.8 end
if (i+0)%4==0  then mult2 = 1.3 end
end
if percent2 > 0.75 then
 percent2 = 0.75

end
if percent2 > 0.7 then
 if percent < 0 then
percent = -0.7
else
percent = 0.7
end

end
icon:translate(mult2*percent*height/2, perf*mult*percent2*height/2, 0)
                                          --  this calls the absolute value function we declared earlier

        end
    end
end