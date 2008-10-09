//
//  CoreAnimationRenderer.m
//  RouteMe
//
//  Created by Joseph Gentle on 9/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMCoreAnimationRenderer.h"
#import <QuartzCore/QuartzCore.h>
#import "RMTile.h"
#import "RMTileLoader.h"
#import "RMPixel.h"
#import "RMTileImage.h"
#import "RMTileImageSet.h"

@implementation RMCoreAnimationRenderer

- (id) initForView: (UIView*)view WithContent: (RMMapContents *)_contents
{
	if (![super initForView:view WithContent:_contents])
		return nil;

	layer = [[CAScrollLayer layer] retain];
	layer.anchorPoint = CGPointMake(0.0f, 0.0f);
	layer.masksToBounds = YES;
	layer.frame = [view bounds];
	
	NSMutableDictionary *customActions=[NSMutableDictionary dictionaryWithDictionary:[layer actions]];
	[customActions setObject:[NSNull null] forKey:@"sublayers"];
	layer.actions = customActions;
	
	layer.delegate = self;
	
	[[view layer] addSublayer:layer]; 
	
	return self;
}

-(void)mapImageLoaded: (NSNotification*)notification
{
}

- (id<CAAction>)actionForLayer:(CALayer *)theLayer
                        forKey:(NSString *)key
{
	if (theLayer == layer)
	{
//		NSLog(@"base layer key: %@", key);
		return nil;
	}
	
	//	|| [key isEqualToString:@"onLayout"]
	if ([key isEqualToString:@"position"]
		|| [key isEqualToString:@"bounds"])
		return nil;
//		return (id<CAAction>)[NSNull null];
	else
	{
//		NSLog(@"key: %@", key);
		
		return nil;
	}
}

- (void)tileAdded: (RMTile) tile WithImage: (RMTileImage*) image
{
	NSLog(@"tileAdded: %d %d %d at %f %f %f %f", tile.x, tile.y, tile.zoom, image.screenLocation.origin.x, image.screenLocation.origin.y,
		  image.screenLocation.size.width, image.screenLocation.size.height);
	
//	NSLog(@"tileAdded");
	[image makeLayer];
	
	CALayer *sublayer = [image layer];
	
	sublayer.delegate = self;
	
	[layer addSublayer:sublayer];
}

-(void) tileRemoved: (RMTile) tile
{
	RMTileImage *image = [[content imagesOnScreen] imageWithTile:tile];
	
	NSLog(@"tileRemoved: %d %d %d at %f %f %f %f", tile.x, tile.y, tile.zoom, image.screenLocation.origin.x, image.screenLocation.origin.y,
		  image.screenLocation.size.width, image.screenLocation.size.height);
	
	[[image layer] removeFromSuperlayer];
}

-(NSString*) description
{
	return @"CoreAnimation map renderer";
}

/*
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
*/

@end
