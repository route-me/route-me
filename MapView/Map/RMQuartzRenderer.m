//
//  QuartzRenderer.m
//  RouteMe
//
//  Created by Joseph Gentle on 8/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMQuartzRenderer.h"
#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif
#import "RMMapContents.h"
#import "RMTileImage.h"

@implementation RMQuartzRenderer

- (id) initForView: (UIView*)_view WithContent: (RMMapContents *)_contents
{
	if (![super initForView:view WithContent:_contents])
		return nil;

	// We do not retain this so there's not a circular dependancy.
	view = _view;
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

- (void)drawRect:(CGRect)rect
{
	[[content imagesOnScreen] drawRect:rect];
}

- (void)setNeedsDisplay
{
	[view setNeedsDisplay];
}

- (void)tileDidFinishLoading: (RMTileImage *)image
{
	[view setNeedsDisplay];
}

@end
