//
//  FileTileImage.m
//  RouteMe
//
//  Created by Joseph Gentle on 2/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMFileTileImage.h"


@implementation RMFileTileImage

-(id)initWithTile: (RMTile) _tile FromFile: (NSString*) file
{
	if (![super initWithTile:_tile])
		return nil;
	
	// From the example in the documentation... :-/
/*    CFURLRef url = CFURLCreateWithFileSystemPath (NULL, (CFStringRef)file, kCFURLPOSIXPathStyle, false);
    CGDataProviderRef provider = CGDataProviderCreateWithURL (url);
    CFRelease (url);
    image = CGImageCreateWithPNGDataProvider (provider, NULL, true, kCGRenderingIntentDefault);
*/	
	image = [[UIImage alloc] initWithContentsOfFile:file];
	[image retain];
//	[self setImageToData:data];
	
	return self;
}

@end
