//
//  LayeredTileImageSet.m
//  RouteMe
//
//  Created by Joseph Gentle on 9/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "LayeredTileLoader.h"
#import "ScreenProjection.h"
#import <QuartzCore/QuartzCore.h>
#import "MathUtils.h"

@implementation LayeredTileLoader

@synthesize layer;

- (id) init
{
	if (![self initForScreen:nil FromImageSource:nil])
		return nil;
	
	return self;
}

- (id) initForScreen: (ScreenProjection*)screen FromImageSource: (id<TileSource>)source
{
	if (![super initForScreen:screen FromImageSource:source])
		return nil;
	
	layer = [CAScrollLayer layer];
	layer.anchorPoint = CGPointMake(0.0f, 0.0f);
	
	if (screen != nil)
	{
		layer.frame = [screen screenBounds];
		layerPositionOffset = [screen topLeft];
	}
	
	CALayer *sublayer = [CALayer layer];
	sublayer.frame = CGRectMake(100, 100, 256, 256);
	NSString *path = [[NSBundle mainBundle] pathForResource:@"loading" ofType:@"png"];
	CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename([path UTF8String]);
	CGImageRef image = CGImageCreateWithPNGDataProvider(dataProvider, NULL, FALSE, kCGRenderingIntentDefault);
	sublayer.contents = (id)image;

	[layer addSublayer:sublayer];

	return self;
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
	transform = CATransform3DScale(transform, zoomFactor, zoomFactor, 1.0f);
	transform = CATransform3DTranslate(transform, -center.x, -center.y, 0.0f);
	layer.transform = transform;
	
	[super zoomByFactor:zoomFactor Near:center];
	
	[CATransaction commit];
}


//-(id) initWithBounds: 

@end
