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
#import "LayerToScreenProjection.h"

@implementation CoreAnimationRenderer

- (id) initWithView: (MapView *)_view
{
	ScreenProjection *_proj = [[ScreenProjection alloc] initWithBounds:[_view bounds]];
	//[[LayerToScreenProjection alloc] initWithBounds:[_view bounds] InLayer:[_view layer]];
	
	if (![super initWithView:_view ProjectingIn:_proj])
		return nil;
	
	//	tileLayer.position = CGPointMake(0.0f,0.0f);
	//	tileLayer.transform = CATransform3DIdentity;
	//	tileLayer.bounds = [view bounds];

	tileLoader = [[LayeredTileLoader alloc] initForScreen:screenProjection FromImageSource:[view tileSource]];
	/*
	layer = [CAScrollLayer layer];
	layer.anchorPoint = CGPointMake(0.0f, 0.0f);
	layer.frame = [view bounds];
	*/
	
//	[layer addSublayer:sublayer];
	
	[view.layer addSublayer:[tileLoader layer]]; 
	
	return self;
}

-(void)mapImageLoaded: (NSNotification*)notification
{
}

-(void) recalculateImageSet
{
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:0.0f]
					 forKey:kCATransactionAnimationDuration];
	
	[CATransaction setValue:(id)kCFBooleanTrue
					 forKey:kCATransactionDisableActions];
	
	[tileLoader assemble];
	
	[CATransaction commit];
}

-(void) moveToMercator: (MercatorPoint) point
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
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:0.0f]
					 forKey:kCATransactionAnimationDuration];
	
	[CATransaction setValue:(id)kCFBooleanTrue
					 forKey:kCATransactionDisableActions];
	
	[super moveBy:delta];
	[tileLoader moveBy:delta];

	[CATransaction commit];
}

- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center
{
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:0.0f]
					 forKey:kCATransactionAnimationDuration];
	
	[CATransaction setValue:(id)kCFBooleanTrue
					 forKey:kCATransactionDisableActions];
	[super zoomByFactor:zoomFactor Near:center];
	[tileLoader zoomByFactor:zoomFactor Near:center];
	
	[CATransaction commit];
}


@end
