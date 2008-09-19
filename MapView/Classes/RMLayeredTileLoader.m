//
//  LayeredTileImageSet.m
//  RouteMe
//
//  Created by Joseph Gentle on 9/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMLayeredTileLoader.h"
#import "RMScreenProjection.h"
#import <QuartzCore/QuartzCore.h>
#import "RMTileImage.h"

@implementation RMLayeredTileLoader

@synthesize layer;

- (id) init
{
	if (![self initForScreen:nil FromImageSource:nil])
		return nil;
	
	return self;
}

- (id) initForScreen: (RMScreenProjection*)screen FromImageSource: (id<RMTileSource>)source
{
	if (![super initForScreen:screen FromImageSource:source])
		return nil;
	
	layer = [CAScrollLayer layer];
	layer.anchorPoint = CGPointMake(0.0f, 0.0f);
	layer.masksToBounds = YES;
	if (screen != nil)
	{
		layer.frame = [screen screenBounds];
//		layerPositionOffset = [screen topLeft];
	}
	
//	CALayer *sublayer = [CALayer layer];
//	sublayer.frame = CGRectMake(160, 100, 256, 256);
//	NSString *path = [[NSBundle mainBundle] pathForResource:@"loading" ofType:@"png"];
//	CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename([path UTF8String]);
//	CGImageRef image = CGImageCreateWithPNGDataProvider(dataProvider, NULL, FALSE, kCGRenderingIntentDefault);
//	sublayer.contents = (id)image;
//	[layer addSublayer:sublayer];
	
	return self;
}

- (void)tileAdded: (RMTile) tile WithImage: (RMTileImage*) image;
{
	[image makeLayer];
	
	CALayer *sublayer = [image layer];
	
//	CGRect frame = image.screenLocation;

//	frame.origin.x -= layer.position.x;
//	frame.origin.y -= layer.position.y;
	
//	NSLog(@"Frame at %f %f %f,%f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
//	NSLog(@"frame position %f,%f", layer.position.x, layer.position.y);
	
//	sublayer.frame = frame;//GRectMake(layer.position.x, layer.position.y, 256, 256);
	
	[layer addSublayer:sublayer];
	
//	NSLog(@"added subimage");
}

-(void) tileRemoved: (RMTile) tile
{
	RMTileImage *image = [images imageWithTile:tile];

	[[image layer] removeFromSuperlayer];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:MapImageRemovedFromScreenNotification object:image];
	
//	NSLog(@"subimage removed");
}

//-(id) initWithBounds: 

@end
