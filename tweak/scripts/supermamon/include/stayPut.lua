--[[ *******************************************************
stayPut library function v1.1x
by @supermamon (github.com/supermamon/cylinder-scripts/)

Description:
	Keeps the page on the same position while scrolling

Parameters:
	page	: requires page only. 
				-- no guarantees if icon is passed
	percent	: percentage of transition
	width	: removed
	
v1.1 2014-02-16: Removed last parameter
v1.0 2014-02-13: First Release
******************************************************** ]]
return function (page, offset)
    page:translate(offset, 0, 0)
end