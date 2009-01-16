//
//  MapRenderer.m
//  RouteMe
//
//  Created by Joseph Gentle on 9/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMMapRenderer.h"

#import "RMTileImage.h"

@implementation RMMapRenderer

// Designated initialiser
- (id) initWithContent: (RMMapContents *)_contents
{
	if (![super init])
		return nil;

	content = _contents;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapImageLoaded:) name:RMMapImageLoadedNotification object:nil];
	
	return self;
}

-(void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void) setNeedsDisplay
{
	
}

-(void)mapImageLoaded: (NSNotification*)notification
{
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{ }

- (void)setFrame:(CGRect)frame
{
}


- (CALayer*) layer
{
	return nil;
}



@end
