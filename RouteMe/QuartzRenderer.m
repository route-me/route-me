//
//  QuartzRenderer.m
//  RouteMe
//
//  Created by Joseph Gentle on 8/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "QuartzRenderer.h"
#import "TileImageSet.h"
#import "MapView.h"

#import "FractalTileProjection.h"
#import "TileSource.h"

#import "ScreenProjection.h"

@implementation QuartzRenderer

- (id) initWithView: (MapView *)_view
{
	if (![super initWithView:_view])
		return nil;
	
	imageSet = [[TileImageSet alloc] init];
	
	return self;
}

-(void) recalculateImageSet
{
//	NSLog(@"recalc");
	TileRect tileRect = [[[view tileSource] tileProjection] project:screenProjection];
	[imageSet assembleFromRect:tileRect FromImageSource:[view tileSource] ToDisplayIn:[view bounds] WithTileDelegate:self];
}

- (void)drawRect:(CGRect)rect
{
	[imageSet draw];
}

- (void)setNeedsDisplay
{
	int loadedZoom = [imageSet loadedZoom];
	float scale = [screenProjection scale];
	int properZoom = [[[view tileSource] tileProjection] calculateNormalisedZoomFromScale:scale];
	if (![imageSet containsRect:[view bounds]]
		|| loadedZoom != properZoom)
	{
//		NSLog(@"loadedZoom = %d properZoom = %d", loadedZoom, properZoom);
		
//		CGRect bounds = [view bounds];
//		NSLog(@"view bounds: %f x %f  %f x %f", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
		
//		CGRect loadedBounds = [imageSet loadedBounds];
//		NSLog(@"loadedBounds: %f x %f  %f x %f", loadedBounds.origin.x, loadedBounds.origin.y, loadedBounds.size.width, loadedBounds.size.height);
		
		[self recalculateImageSet];
	}
	
	[super setNeedsDisplay];	
}

- (void)moveBy: (CGSize) delta
{
	[super moveBy:delta];
	[imageSet moveBy:delta];
	[self setNeedsDisplay];	
}

- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center
{
	[super zoomByFactor:zoomFactor Near:center];
	[imageSet zoomByFactor:zoomFactor Near:center];
	[self setNeedsDisplay];	
}

- (void)tileDidFinishLoading: (TileImage *)image
{
	[view setNeedsDisplay];
}

@end
