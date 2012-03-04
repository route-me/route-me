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
#import "RMGlobalConstants.h"
#import "RMTileImage.h"
#import "RMWebTileImage.h"
#import "RMTileLoader.h"
#import "RMFileTileImage.h"
#import "RMDBTileImage.h"
#import "RMTileCache.h"
#import "RMPixel.h"
#import <QuartzCore/QuartzCore.h>

@implementation RMTileImage

@synthesize tile, layer, lastUsedTime;

- (id) initWithTile: (RMTile)_tile
{
	if (![super init])
		return nil;
	
	tile = _tile;
	layer = nil;
	lastUsedTime = nil;
	screenLocation = CGRectZero;

        [self makeLayer];

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

	[layer release]; layer = nil;
	[lastUsedTime release]; lastUsedTime = nil;
	
	[super dealloc];
}

-(void)draw
{
}

+ (RMTileImage*)imageForTile:(RMTile) _tile withURL: (NSString*)url
{
	return [[[RMWebTileImage alloc] initWithTile:_tile FromURL:url] autorelease];
}

+ (RMTileImage*)imageForTile:(RMTile) _tile fromFile: (NSString*)filename
{
	return [[[RMFileTileImage alloc] initWithTile:_tile FromFile:filename] autorelease];
}

+ (RMTileImage*)imageForTile:(RMTile) tile withData: (NSData*)data
{
	UIImage *image = [[UIImage alloc] initWithData:data];
	RMTileImage *tileImage;

	if (!image)
		return nil;

	tileImage = [[self alloc] initWithTile:tile];
	[tileImage updateImageUsingImage:image];
	[image release];
	return [tileImage autorelease];
}

+ (RMTileImage*)imageForTile:(RMTile) _tile fromDB: (FMDatabase*)db
{
	return [[[RMDBTileImage alloc] initWithTile: _tile fromDB:db] autorelease];
}

-(void) cancelLoading
{
	[[NSNotificationCenter defaultCenter] postNotificationName:RMMapImageLoadingCancelledNotification
														object:self];
}


- (BOOL)updateImageUsingData: (NSData*) data
{
    UIImage *image = [UIImage imageWithData:data];
    if ( !image ) {
        return NO;
    }
       [self updateImageUsingImage:image];

       NSDictionary *d = [NSDictionary dictionaryWithObject:data forKey:@"data"];
       [[NSNotificationCenter defaultCenter] postNotificationName:RMMapImageLoadedNotification object:self userInfo:d];
    
    return YES;
}

- (void)updateImageUsingImage: (UIImage*) rawImage
{
	layer.contents = (id)[rawImage CGImage];
//	[self animateIn];
}

- (BOOL)isLoaded
{
	return (layer != nil && layer.contents != NULL);
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
		layer.anchorPoint = CGPointZero;
		layer.bounds = CGRectMake(0, 0, screenLocation.size.width, screenLocation.size.height);
		layer.position = screenLocation.origin;
		
		NSMutableDictionary *customActions=[NSMutableDictionary dictionaryWithDictionary:[layer actions]];
		
		[customActions setObject:[NSNull null] forKey:@"position"];
		[customActions setObject:[NSNull null] forKey:@"bounds"];
		[customActions setObject:[NSNull null] forKey:kCAOnOrderOut];
        [customActions setObject:[NSNull null] forKey:kCAOnOrderIn];

		CATransition *fadein = [[CATransition alloc] init];
		fadein.duration = 0.3;
		fadein.type = kCATransitionReveal;
		[customActions setObject:fadein forKey:@"contents"];
		[fadein release];

		
		layer.actions=customActions;
		
		layer.edgeAntialiasingMask = 0;
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
		// layer.frame = screenLocation;
		layer.position = screenLocation.origin;
		layer.bounds = CGRectMake(0, 0, screenLocation.size.width, screenLocation.size.height);
	}
	
	[self touch];
}

- (void) displayProxy:(UIImage*) img
{
        layer.contents = (id)[img CGImage]; 
}

@end
