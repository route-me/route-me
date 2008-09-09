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
#import "LayeredTileImageSet.h"
#import "MathUtils.h"

@implementation CoreAnimationRenderer

- (id) initWithView: (MapView *)_view
{
	if (![super initWithView:_view])
		return nil;
	
	//	tileLayer.position = CGPointMake(0.0f,0.0f);
	//	tileLayer.transform = CATransform3DIdentity;
	//	tileLayer.bounds = [view bounds];
	
	layer = [CAScrollLayer layer];
	layer.anchorPoint = CGPointMake(0.0f, 0.0f);
	layer.frame = [view bounds];
	
	CALayer *sublayer = [CALayer layer];
	sublayer.frame = CGRectMake(100, 100, 256, 256);
	NSString *path = [[NSBundle mainBundle] pathForResource:@"loading" ofType:@"png"];
	CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename([path UTF8String]);
	CGImageRef image = CGImageCreateWithPNGDataProvider(dataProvider, NULL, FALSE, kCGRenderingIntentDefault);
	sublayer.contents = (id)image;

	[layer addSublayer:sublayer];
	
	[view.layer addSublayer:layer]; 
	
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
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:0.0f]
					 forKey:kCATransactionAnimationDuration];
		
	layer.position = TranslateCGPointBy(layer.position, delta);
	[super moveBy:delta];

	[CATransaction commit];
	
}

- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center
{
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:0.0f]
					 forKey:kCATransactionAnimationDuration];
	
	CATransform3D transform = layer.transform;
	transform = CATransform3DTranslate(transform, center.x, center.y, 0.0f);
	transform = CATransform3DScale(transform, 1.0f/zoomFactor, 1.0f/zoomFactor, 1.0f);
	transform = CATransform3DTranslate(transform, -center.x, -center.y, 0.0f);
	layer.transform = transform;
	
	[super zoomByFactor:zoomFactor Near:center];

	[CATransaction commit];
}


@end
