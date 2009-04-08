//
//  RMCoreAnimationRenderer.m
//
// Copyright (c) 2008, Route-Me Contributors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#import "RMCoreAnimationRenderer.h"
#import <QuartzCore/QuartzCore.h>
#import "RMTile.h"
#import "RMTileLoader.h"
#import "RMPixel.h"
#import "RMTileImage.h"
#import "RMTileImageSet.h"

@implementation RMCoreAnimationRenderer

- (id) initWithContent: (RMMapContents *)_contents
{
	if (![super initWithContent:_contents])
		return nil;
	
	// NOTE: RMMapContents may still be initialising when this function
	//       is called. Be careful using any of methods - they might return
	//       strange data.

	layer = [[CAScrollLayer layer] retain];
	layer.anchorPoint = CGPointMake(0.0f, 0.0f);
	layer.masksToBounds = YES;
	// If the frame is set incorrectly here, it will be fixed when setRenderer is called in RMMapContents
	layer.frame = [content screenBounds];
	
	NSMutableDictionary *customActions = [NSMutableDictionary dictionaryWithDictionary:[layer actions]];
	[customActions setObject:[NSNull null] forKey:@"sublayers"];
	layer.actions = customActions;
	
	layer.delegate = self;
	
	return self;
}

-(void) dealloc
{
	[layer release];
	[super dealloc];
}

/// \bug this is a no-op
-(void)mapImageLoaded: (NSNotification*)notification
{
}

- (id<CAAction>)actionForLayer:(CALayer *)theLayer
                        forKey:(NSString *)key
{
	if (theLayer == layer)
	{
//		RMLog(@"base layer key: %@", key);
		return nil;
	}
	
	//	|| [key isEqualToString:@"onLayout"]
	if ([key isEqualToString:@"position"]
		|| [key isEqualToString:@"bounds"])
		return nil;
//		return (id<CAAction>)[NSNull null];
	else
	{
//		RMLog(@"key: %@", key);
		
		return nil;
	}
}

- (void)tileAdded: (RMTile) tile WithImage: (RMTileImage*) image
{
//	RMLog(@"tileAdded: %d %d %d at %f %f %f %f", tile.x, tile.y, tile.zoom, image.screenLocation.origin.x, image.screenLocation.origin.y,
//		  image.screenLocation.size.width, image.screenLocation.size.height);
	
//	RMLog(@"tileAdded");
	[image makeLayer];
	
	CALayer *sublayer = [image layer];
	
	sublayer.delegate = self;
	
	[layer addSublayer:sublayer];
}

-(void) tileRemoved: (RMTile) tile
{
	RMTileImage *image = [[content imagesOnScreen] imageWithTile:tile];
	
//	RMLog(@"tileRemoved: %d %d %d at %f %f %f %f", tile.x, tile.y, tile.zoom, image.screenLocation.origin.x, image.screenLocation.origin.y,
//		  image.screenLocation.size.width, image.screenLocation.size.height);
	
	[[image layer] removeFromSuperlayer];
}

- (void)setFrame:(CGRect)frame
{
	layer.frame = [content screenBounds];
}

- (CALayer*) layer
{
	return layer;
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
