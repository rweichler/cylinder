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

#import "CLEffect.h"
#import <Defines.h>

@implementation CLEffect
@synthesize name=_name, path=_path, directory=_directory, broken=_broken, selected=_selected, cell=_cell;

+ (CLEffect*)effectWithPath:(NSString*)path {
	return [[[self alloc] initWithPath:path] autorelease];
}

- (id)initWithPath:(NSString*)path {
	BOOL isDir;
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];

    NSArray *components = [path pathComponents];
    NSArray *ext = [path.lastPathComponent componentsSeparatedByString: @"."];
	
    if (!exists || isDir || ![ext.lastObject isEqualToString:@"lua"]) {
		[self release];
		return nil;
	}

    NSMutableString *name = [NSMutableString string];
    for(int i = 0; i < ext.count - 1; i++)
    {
        [name appendString:[ext objectAtIndex:i]];
        if(i != ext.count - 2) [name appendString:@"."];
    }

	if ((self = [super init])) {
		self.name = name;
        self.path = path;
        self.directory = [components objectAtIndex:(components.count - 2)];
	}
	return self;
}

- (void)dealloc {
	self.name = nil;
	self.path = nil;
    self.directory = nil;
	[super dealloc];
}

@end
