//
//  Tile.m
//  Images
//
//  Created by Joseph Gentle on 13/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TileImage.h"
#import "WebTileImage.h"

@implementation TileImage

@synthesize screenLocation;

- (id)init
{
	if (![super init])
		return nil;
	
	if ([[self class] isEqual:[TileImage class]])
	{
		[NSException raise:@"Abstract Class Exception" format:@"Error, attempting to instantiate TileImage directly."];
		[self release];
		return nil; 
	}
	
	image = nil;
	
	return self;
}

- (void)dealloc
{
	[image release];
	[super dealloc];
}

- (void)drawInRect:(CGRect)rect
{
	[image drawInRect:rect];
//	[image drawAtPoint:rect.origin];
}

-(void)draw
{
	[self drawInRect:screenLocation];	
}

+ (TileImage*)imageFromURL: (NSString*)url
{
	return [[[WebTileImage alloc] initFromURL:url] autorelease];
}

- (void)setDelegate:(id) delegate
{
	
}

-(void) cancelLoading
{
	
}

- (void)setImageToData: (NSData*) data
{
	image = [[UIImage imageWithData:data] retain];
}

@end
