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
