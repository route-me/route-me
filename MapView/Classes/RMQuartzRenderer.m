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

#import "RMTileLoader.h"

#import "RMFractalTileProjection.h"
#import "RMTileSource.h"

#import "RMScreenProjection.h"

@implementation RMQuartzRenderer

- (id) initWithView: (id<RenderingTarget>)_view
{
	if (![super initWithView:_view])
		return nil;
	
	tileLoader = [[RMTileLoader alloc] initForScreen:screenProjection FromImageSource:[view tileSource]];
	
	return self;
}

-(void) dealloc
{
	[tileLoader release];
	[super dealloc];
}

-(void) recalculateImageSet
{
	[tileLoader assemble];
}

- (void)drawRect:(CGRect)rect
{
	[tileLoader draw];
}

-(void) moveToMercator: (RMMercatorPoint) point
{
	[tileLoader clearLoadedBounds];
	[super moveToMercator:point];
}
-(void) moveToLatLong: (CLLocationCoordinate2D) point
{
	[tileLoader clearLoadedBounds];
	[super moveToLatLong:point];
}

- (void)moveBy: (CGSize) delta
{
	[super moveBy:delta];
	[tileLoader moveBy:delta];
}

- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center
{
	[super zoomByFactor:zoomFactor Near:center];
	[tileLoader zoomByFactor:zoomFactor Near:center];
}

- (void)tileDidFinishLoading: (RMTileImage *)image
{
	[view setNeedsDisplay];
}

@end
