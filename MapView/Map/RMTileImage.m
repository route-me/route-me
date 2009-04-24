//
//  RMTileImage.m
//
// Copyright (c) 2008-2009, Route-Me Contributors
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

#import "RMTileImage.h"
#import "RMWebTileImage.h"
#import "RMTileLoader.h"
#import "RMFileTileImage.h"
#import "RMTileCache.h"
#import "RMPixel.h"
#import <QuartzCore/QuartzCore.h>

/// \bug magic string literals should be moved to central location
NSString * const RMMapImageLoadedNotification = @"MapImageLoaded";
NSString * const RMMapImageLoadingCancelledNotification = @"MapImageLoadingCancelled";

@implementation RMTileImage

@synthesize tile, layer, image, lastUsedTime;

- (id) initWithTile: (RMTile)_tile
{
	if (![super init])
		return nil;
	
	tile = _tile;
	image = nil;
	layer = nil;
	loadingPriorityCount = 0;
	lastUsedTime = nil;
	dataPending = nil;
	screenLocation = CGRectMake(0, 0, 0, 0);
	
	[self touch];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tileRemovedFromScreen:)
												 name:RMMapImageRemovedFromScreenNotification object:self];
		
	return self;
}
	 
-(void) tileRemovedFromScreen: (NSNotification*) notification
{
	[self cancelLoading];
}

-(id) init
{
	[NSException raise:@"Invalid initialiser" format:@"Use the designated initialiser for TileImage"];
	[self release];
	return nil;
}

+ (RMTileImage*) dummyTile: (RMTile)tile
{
	return [[[RMTileImage alloc] initWithTile:tile] autorelease];
}

- (void)dealloc
{
//	RMLog(@"Removing tile image %d %d %d", tile.x, tile.y, tile.zoom);
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];

//	if (image)
//		CGImageRelease(image);

	[image release]; image = nil;
	[layer release]; layer = nil;
	[dataPending release]; dataPending = nil;
	[lastUsedTime release]; lastUsedTime = nil;
	
	[super dealloc];
}
/*
- (id) increaseLoadingPriority
{
	loadingPriorityCount++;
	return self;
}
- (id) decreaseLoadingPriority
{
	loadingPriorityCount--;
	if (loadingPriorityCount == 0)
		[self cancelLoading];
	return self;
}*/

- (void)drawInRect:(CGRect)rect
{
	[image drawInRect:rect];
/*	if (image != NULL)
	{
		CGContextRef context = UIGraphicsGetCurrentContext();

		RMLog(@"image width = %f", CGImageGetWidth(image));
		//		CGContextClipToRect(context, rect);
		CGContextDrawImage(context, rect, image);
	}*/
}

-(void)draw
{
	[self drawInRect:screenLocation];
}

+ (RMTileImage*)imageWithTile: (RMTile) _tile FromURL: (NSString*)url
{
	return [[[RMWebTileImage alloc] initWithTile:_tile FromURL:url] autorelease];
}

+ (RMTileImage*)imageWithTile: (RMTile) _tile FromFile: (NSString*)filename
{
	return [[[RMFileTileImage alloc] initWithTile: _tile FromFile:filename] autorelease];
}

+ (RMTileImage*)imageWithTile: (RMTile) tile FromData: (NSData*)data
{
	RMTileImage *image = [[RMTileImage alloc] initWithTile:tile];
	[image setImageToData:data];
	return [image autorelease];
}

-(void) cancelLoading
{
	[[NSNotificationCenter defaultCenter] postNotificationName:RMMapImageLoadingCancelledNotification
														object:self];
}

- (void) loadPendingData: (NSNotification*)notification
{
	if (dataPending != nil)
	{
		[self setImageToData:dataPending];
		[dataPending release];
		dataPending = nil;
		
//		RMLog(@"loadPendingData");
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:RMResumeExpensiveOperations object:nil];
}

- (void)setImageToData: (NSData*) data
{
	if ([RMMapContents performExpensiveOperations] == NO)
	{
//		RMLog(@"storing data for later loading");
		[data retain];
		[dataPending release];
		dataPending = data;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPendingData:) name:RMResumeExpensiveOperations object:nil];
		return;
	}

	UIImage *tileImage = [[UIImage alloc] initWithData:data];

	if (layer == nil)
	{
		image = [tileImage retain];
	}
	else
	{
		CGImageRef cgImage = [tileImage CGImage];
		layer.contents = (id)cgImage;
	}
	
	[tileImage release];
	
	NSDictionary *d = [NSDictionary dictionaryWithObject:data forKey:@"data"];
	[[NSNotificationCenter defaultCenter] postNotificationName:RMMapImageLoadedNotification
														object:self
													  userInfo:d];
}

- (BOOL)isLoaded
{
	return image != nil
		|| (layer != nil && layer.contents != NULL);
}

- (NSUInteger)hash
{
	return (NSUInteger)RMTileHash(tile);
}

-(void) touch
{
	[lastUsedTime release];
	lastUsedTime = [[NSDate date] retain];
}

- (BOOL)isEqual:(id)anObject
{
	if (![anObject isKindOfClass:[RMTileImage class]])
		return NO;

	return RMTilesEqual(tile, [(RMTileImage*)anObject tile]);
}

- (void)makeLayer
{
	if (layer == nil)
	{
		layer = [[CALayer alloc] init];
		layer.contents = nil;
		layer.anchorPoint = CGPointMake(0.0f, 0.0f);
		layer.bounds = CGRectMake(0, 0, screenLocation.size.width, screenLocation.size.height);
		layer.position = screenLocation.origin;
		
		NSMutableDictionary *customActions=[NSMutableDictionary dictionaryWithDictionary:[layer actions]];
		
		[customActions setObject:[NSNull null] forKey:@"position"];
		[customActions setObject:[NSNull null] forKey:@"bounds"];
		[customActions setObject:[NSNull null] forKey:kCAOnOrderOut];
		
/*		CATransition *fadein = [[CATransition alloc] init];
		fadein.duration = 2.0;
		fadein.type = kCATransitionFade;
		[customActions setObject:fadein forKey:kCAOnOrderIn];
		[fadein release];
*/
		[customActions setObject:[NSNull null] forKey:kCAOnOrderIn];
		
		layer.actions=customActions;
		
		layer.edgeAntialiasingMask = 0;
		
//		RMLog(@"location %f %f", screenLocation.origin.x, screenLocation.origin.y);

	//		RMLog(@"layer made");
	}
	
	if (image != nil)
	{
		layer.contents = (id)[image CGImage];
		[image release];
		image = nil;
//		RMLog(@"layer contents set");
	}
}

- (void)moveBy: (CGSize) delta
{
	self.screenLocation = RMTranslateCGRectBy(screenLocation, delta);
}

- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center
{
	self.screenLocation = RMScaleCGRectAboutPoint(screenLocation, zoomFactor, center);
}

- (CGRect) screenLocation
{
	return screenLocation;
}

- (void) setScreenLocation: (CGRect)newScreenLocation
{
//	RMLog(@"location moving from %f %f to %f %f", screenLocation.origin.x, screenLocation.origin.y, newScreenLocation.origin.x, newScreenLocation.origin.y);
	screenLocation = newScreenLocation;
	
	if (layer != nil)
	{
		//		layer.frame = screenLocation;
		layer.position = screenLocation.origin;
		layer.bounds = CGRectMake(0, 0, screenLocation.size.width, screenLocation.size.height);
	}
	
	[self touch];
}

@end
