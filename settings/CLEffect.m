#import "CLEffect.h"
#import <Defines.h>

@implementation CLEffect
@synthesize name=_name, path=_path, pack=_pack, broken=_broken;

+ (CLEffect*)effectWithPath:(NSString*)path {
	return [[[self alloc] initWithPath:path] autorelease];
}

- (id)initWithPath:(NSString*)path {
	BOOL isDir;
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];

    NSArray *ext = [path.lastPathComponent componentsSeparatedByString: @"."];
	
    if (!exists || isDir || ![ext.lastObject isEqualToString:@"lua"]) {
		[self release];
		return nil;
	}

    NSMutableString *name = [NSMutableString string];
    for(int i = 0; i < ext.count - 1; i++)
    {
        [name appendString:ext[i]];

        if(i != ext.count - 2) [name appendString:@"."];
    }

    if([name isEqualToString:@"EXAMPLE"])
    {
        [self release];
        return nil;
    }
	
	if ((self = [super init])) {
		self.name = name;
        self.path = path;
	}
	return self;
}

- (void)dealloc {
	self.name = nil;
	self.path = nil;
	[super dealloc];
}

@end
