--[[ *******************************************************
fade library function v1.1x
by @supermamon (github.com/supermamon/cylinder-scripts/)

Description:
Fades either the icon or page depending on which one is
 passed to the view parameter

Parameters:
	view	: page or icon
	percent	: percentage of transition

v1.1 2014-02-16: Compatibility update for Cylinder v0.13.2.15
v1.0 2014-02-13: First Release
******************************************************** ]]
return function (view, percent)
    view.alpha = 1 - math.abs(percent)
end
