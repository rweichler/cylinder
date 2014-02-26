/*
Copyright (C) 2014 Reed Weichler

This file is part of Cylinder.

Cylinder is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Cylinder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Cylinder.  If not, see <http://www.gnu.org/licenses/>.
*/


//NOTE: See issue #1. This is horrible practice.
//I should just build these separately and link them,
//but when I tried it, I always got some linker error.
//It should be a easy fix for anyone who is experienced
//with MobileSubstrate tweaks, but I couldn't figure it out
//If anyone has the time, I'd appreciate it if you fixed
//this for me. Thanks.

#import "Tweak.m"
#import "luashit.m"
#import "lua_UIView.m"
#import "UIView+Cylinder.m"
#import "CALayer+Cylinder.m"
