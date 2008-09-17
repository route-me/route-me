//
//  QuartzRenderer.m
//  RouteMe
//
//  Created by Joseph Gentle on 8/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "QuartzRenderer.h"
#import "TileLoader.h"
#import "MapView.h"

#import "FractalTileProjection.h"
#import "TileSource.h"

#import "ScreenProjection.h"

@implementation QuartzRenderer

- (id) initWithView: (MapView *)_view
{
	if (![super initWithView:_view])
		return nil;
	
	tileLoader = [[TileLoader alloc] initForScreen:screenProjection FromImageSource:[view tileSource]];
	
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

- (void)tileDidFinishLoading: (TileImage *)image
{
	[view setNeedsDisplay];
}

@end
