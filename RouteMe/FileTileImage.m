//
//  FileTileImage.m
//  RouteMe
//
//  Created by Joseph Gentle on 2/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FileTileImage.h"


@implementation FileTileImage

-(id)initWithTile: (Tile) _tile FromFile: (NSString*) file
{
	if (![super initWithTile:_tile])
		return nil;
	
	image = [[UIImage alloc] initWithContentsOfFile:file];
	[image retain];
//	[self setImageToData:data];
	
	return self;
}

-(void)dealloc
{
	[image release];
	[super dealloc];
}

@end
