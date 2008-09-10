//
//  CoreAnimationRenderer.m
//  RouteMe
//
//  Created by Joseph Gentle on 9/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CoreAnimationRenderer.h"
#import "MapView.h"
#import <QuartzCore/QuartzCore.h>
#import "LayeredTileLoader.h"
#import "MathUtils.h"

@implementation CoreAnimationRenderer

- (id) initWithView: (MapView *)_view
{
	if (![super initWithView:_view])
		return nil;
	
	//	tileLayer.position = CGPointMake(0.0f,0.0f);
	//	tileLayer.transform = CATransform3DIdentity;
	//	tileLayer.bounds = [view bounds];

	imageSet = [[LayeredTileLoader alloc] initForScreen:screenProjection FromImageSource:[view tileSource]];
	/*
	layer = [CAScrollLayer layer];
	layer.anchorPoint = CGPointMake(0.0f, 0.0f);
	layer.frame = [view bounds];
	*/
	
//	[layer addSublayer:sublayer];
	
	[view.layer addSublayer:[imageSet layer]]; 
	
	return self;
}

-(void) recalculateImageSet
{
	//	NSLog(@"recalc");
//	TileRect tileRect = [[[view tileSource] tileProjection] project:screenProjection];
//	[imageSet assembleFromRect:tileRect FromImageSource:[view tileSource] ToDisplayIn:[view bounds] WithTileDelegate:self];
}

- (void)setNeedsDisplay
{
//	int loadedZoom = [imageSet loadedZoom];
//	float scale = [screenProjection scale];
//	int properZoom = [[[view tileSource] tileProjection] calculateNormalisedZoomFromScale:scale];
//	if (![imageSet containsRect:[view bounds]]
//		|| loadedZoom != properZoom)
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

-(void) moveToMercator: (MercatorPoint) point
{
	[super moveToMercator:point];
}
-(void) moveToLatLong: (CLLocationCoordinate2D) point
{
	[super moveToLatLong:point];
}

- (void)moveBy: (CGSize) delta
{
	[imageSet moveBy:delta];
	[super moveBy:delta];
}

- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center
{
	[imageSet zoomByFactor:zoomFactor Near:center];
	[super zoomByFactor:zoomFactor Near:center];
}


@end
