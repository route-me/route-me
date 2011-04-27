//
//  RMTileImageSet.m
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

#import "RMTileImageSet.h"
#import "RMTileImage.h"
#import "RMPixel.h"
#import "RMTileSource.h"

// For notification strings
#import "RMTileLoader.h"

#import "RMMercatorToTileProjection.h"

@implementation RMTileImageSet

@synthesize delegate, tileDepth;

-(id) initWithDelegate: (id) _delegate
{
	if (![super init])
		return nil;
	
	tileSource = nil;
	self.delegate = _delegate;
	images = [[NSMutableSet alloc] init];
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(tileImageLoaded:)
		name:RMMapImageLoadedNotification
		object:nil
	];
	return self;
}

-(void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self removeAllTiles];
	[images release];
	[super dealloc];
}

-(void) removeTile: (RMTile) tile
{
	RMTileImage *img;

	NSAssert(!RMTileIsDummy(tile), @"attempted to remove dummy tile");
	if (RMTileIsDummy(tile))
	{
		RMLog(@"attempted to remove dummy tile...??");
		return;
	}
	
	RMTileImage *dummyTile = [RMTileImage dummyTile:tile];
	img = [images member:dummyTile];
	if (!img) {
		return;
	}

	if ([delegate respondsToSelector: @selector(tileRemoved:)])
	{
		[delegate tileRemoved:tile];
	}

	[[NSNotificationCenter defaultCenter] postNotificationName:RMMapImageRemovedFromScreenNotification object:img];
	[images removeObject:dummyTile];
}

-(void) removeAllTiles
{
	for (RMTileImage * img in [images allObjects]) {
		[self removeTile: img.tile];
	}
}

- (void) setTileSource: (id<RMTileSource>)newTileSource
{
	[self removeAllTiles];

	tileSource = newTileSource;
}

-(void) addTile: (RMTile) tile WithImage: (RMTileImage *)image At: (CGRect) screenLocation
{
	BOOL tileNeeded;

	tileNeeded = YES;
	for (RMTileImage *img in images)
	{
		if (![img isLoaded])
		{
			continue;
		}
		if ([self isTile:tile worseThanTile:img.tile])
		{
			tileNeeded = NO;
			break;
		}
	}
	if (!tileNeeded) {
		return;
	}

	if ([image isLoaded]) {
		[self removeTilesWorseThan:image];
	}

	image.screenLocation = screenLocation;
	[images addObject:image];
	
	if (!RMTileIsDummy(image.tile))
	{
		if([delegate respondsToSelector:@selector(tileAdded:WithImage:)])
		{
			[delegate tileAdded:tile WithImage:image];
		}

		[[NSNotificationCenter defaultCenter] postNotificationName:RMMapImageAddedToScreenNotification object:image];
	}
}

-(void) addTile: (RMTile) tile At: (CGRect) screenLocation
{
	//	RMLog(@"addTile: %d %d", tile.x, tile.y);
	
	RMTileImage *dummyTile = [RMTileImage dummyTile:tile];
	RMTileImage *tileImage = [images member:dummyTile];
	
	if (tileImage != nil)
	{
		[tileImage setScreenLocation:screenLocation];
		[images addObject:dummyTile];
	}
	else
	{
		RMTileImage *image = [tileSource tileImage:tile];
		if (image != nil)
			[self addTile:tile WithImage:image At:screenLocation];
	}
}

// Add tiles inside rect protected to bounds. Return rectangle containing bounds
// extended to full tile loading area
-(CGRect) addTiles: (RMTileRect)rect ToDisplayIn:(CGRect)bounds
{
//	RMLog(@"addTiles: %d %d - %f %f", rect.origin.tile.x, rect.origin.tile.y, rect.size.width, rect.size.height);
	
	RMTile t;
	float pixelsPerTile = bounds.size.width / rect.size.width;
	RMTileRect roundedRect = RMTileRectRound(rect);
	// The number of tiles we'll load in the vertical and horizontal directions
	int tileRegionWidth = (int)roundedRect.size.width;
	int tileRegionHeight = (int)roundedRect.size.height;
	id<RMMercatorToTileProjection> proj = [tileSource mercatorToTileProjection];
	short minimumZoom = [tileSource minZoom], alternateMinimum;

	// Now we translate the loaded region back into screen space for loadedBounds.
	CGRect newLoadedBounds;
	newLoadedBounds.origin.x = bounds.origin.x - (rect.origin.offset.x * pixelsPerTile);
	newLoadedBounds.origin.y = bounds.origin.y - (rect.origin.offset.y * pixelsPerTile);	
	newLoadedBounds.size.width = tileRegionWidth * pixelsPerTile;
	newLoadedBounds.size.height = tileRegionHeight * pixelsPerTile;

	alternateMinimum = zoom - tileDepth - 1;
	if (minimumZoom < alternateMinimum)
	{
		minimumZoom = alternateMinimum;
	}

	for (;;)
	{
		CGRect screenLocation;
		screenLocation.size.width = pixelsPerTile;
		screenLocation.size.height = pixelsPerTile;
		t.zoom = rect.origin.tile.zoom;

		for (t.x = roundedRect.origin.tile.x; t.x < roundedRect.origin.tile.x + tileRegionWidth; t.x++)
		{
			for (t.y = roundedRect.origin.tile.y; t.y < roundedRect.origin.tile.y + tileRegionHeight; t.y++)
			{
				RMTile normalisedTile = [proj normaliseTile: t];

				if (RMTileIsDummy(normalisedTile))
					continue;

				// this regrouping of terms is better for calculation precision (issue 128)		
				screenLocation.origin.x = bounds.origin.x + (t.x - rect.origin.tile.x - rect.origin.offset.x) * pixelsPerTile;		
				screenLocation.origin.y = bounds.origin.y + (t.y - rect.origin.tile.y - rect.origin.offset.y) * pixelsPerTile;

				[self addTile:normalisedTile At:screenLocation];
			}
		}

		// adjust rect for next zoom level down until we're at minimum
		if (--rect.origin.tile.zoom <= minimumZoom)
			break;
		if (rect.origin.tile.x & 1)
			rect.origin.offset.x += 1.0;
		if (rect.origin.tile.y & 1)
			rect.origin.offset.y += 1.0;
		rect.origin.tile.x /= 2;
		rect.origin.tile.y /= 2;
		rect.size.width *= 0.5;
		rect.size.height *= 0.5;
		rect.origin.offset.x *= 0.5;
		rect.origin.offset.y *= 0.5;
		pixelsPerTile = bounds.size.width / rect.size.width;
		roundedRect = RMTileRectRound(rect);
		// The number of tiles we'll load in the vertical and horizontal directions
		tileRegionWidth = (int)roundedRect.size.width;
		tileRegionHeight = (int)roundedRect.size.height;
	}
	
	return newLoadedBounds;
}

-(RMTileImage*) imageWithTile: (RMTile) tile
{
	RMTileImage *dummyTile = [RMTileImage dummyTile:tile];

	return [images member:dummyTile];
}

-(NSUInteger) count
{
	return [images count];
	
}

- (void)moveBy: (CGSize) delta
{
	for (RMTileImage *image in images)
	{
		[image moveBy: delta];
	}
}

- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center
{
	for (RMTileImage *image in images)
	{
		[image zoomByFactor:zoomFactor near:center];
	}
}

/*
- (void) drawRect:(CGRect) rect
{
	for (RMTileImage *image in images)
	{
		[image draw];
	}
}
*/

- (void) printDebuggingInformation
{
	float biggestSeamRight = 0.0f;
	float biggestSeamDown = 0.0f;
	
	for (RMTileImage *image in images)
	{
		CGRect location = [image screenLocation];
/*		RMLog(@"Image at %f, %f %f %f",
			  location.origin.x,
			  location.origin.y,
			  location.origin.x + location.size.width,
			  location.origin.y + location.size.height);
*/
		float seamRight = INFINITY;
		float seamDown = INFINITY;
		
		for (RMTileImage *other_image in images)
		{
			CGRect other_location = [other_image screenLocation];
			if (other_location.origin.x > location.origin.x)
				seamRight = MIN(seamRight, other_location.origin.x - (location.origin.x + location.size.width));
			if (other_location.origin.y > location.origin.y)
				seamDown = MIN(seamDown, other_location.origin.y - (location.origin.y + location.size.height));
		}
		
		if (seamRight != INFINITY)
			biggestSeamRight = MAX(biggestSeamRight, seamRight);
		
		if (seamDown != INFINITY)
			biggestSeamDown = MAX(biggestSeamDown, seamDown);
	}
	
	RMLog(@"Biggest seam right: %f  down: %f", biggestSeamRight, biggestSeamDown);
}

- (void)cancelLoading
{
	for (RMTileImage *image in images)
	{
		[image cancelLoading];
	}
}

- (RMTileImage *)anyTileImage {
	return [images anyObject];
}

- (short)zoom
{
	return zoom;
}

- (void)setZoom:(short)value
{
	if (zoom == value) {
		// no need to act
		return;
	}

	zoom = value;
	for (RMTileImage *image in [images allObjects])
	{
		if (![image isLoaded]) {
			continue;
		}
		[self removeTilesWorseThan:image];
	}
}

- (BOOL)fullyLoaded
{
	BOOL fullyLoaded = YES;

	for (RMTileImage *image in images)
	{
		if (![image isLoaded])
		{
			fullyLoaded = NO;
			break;
		}
	}
	return fullyLoaded;
}

- (void)tileImageLoaded:(NSNotification *)notification
{
	RMTileImage *img = (RMTileImage *)[notification object];

	if (!img || img != [images member:img])
	{
		// i don't contain img, it may be already removed or in another set
		return;
	}

	[self removeTilesWorseThan:img];
}

- (void)removeTilesWorseThan:(RMTileImage *)newImage {
	RMTile newTile = newImage.tile;

	if (newTile.zoom > zoom) {
		// no tiles are worse since this one is too detailed to keep long-term
		return;
	}

	for (RMTileImage *oldImage in [images allObjects])
	{
		RMTile oldTile = oldImage.tile;

		if (oldImage == newImage)
		{
			continue;
		}
		if ([self isTile:oldTile worseThanTile:newTile])
		{
			[oldImage cancelLoading];
			[self removeTile:oldTile];
		}
	}
}

- (BOOL)isTile:(RMTile)subject worseThanTile:(RMTile)object
{
	short subjZ, objZ;
	uint32_t sx, sy, ox, oy;

	objZ = object.zoom;
	if (objZ > zoom)
	{
		// can't be worse than this tile, it's too detailed to keep long-term
		return NO;
	}

	subjZ = subject.zoom;
	if (subjZ + tileDepth >= zoom && subjZ <= zoom)
	{
		// this tile isn't bad, it's within zoom limits
		return NO;
	}

	sx = subject.x;
	sy = subject.y;
	ox = object.x;
	oy = object.y;

	if (subjZ < objZ)
	{
		// old tile is larger & blurrier
		unsigned int dz = objZ - subjZ;

		ox >>= dz;
		oy >>= dz;
	}
	else if (objZ < subjZ)
	{
		// old tile is smaller & more detailed
		unsigned int dz = subjZ - objZ;

		sx >>= dz;
		sy >>= dz;
	}
	if (sx != ox || sy != oy)
	{
		// Tiles don't overlap
		return NO;
	}

	if (abs(zoom - subjZ) < abs(zoom - objZ))
	{
		// subject is closer to desired zoom level than object, so it's not worse
		return NO;
	}

	return YES;
}

-(void) removeTilesOutsideOf: (RMTileRect)rect
{
	uint32_t minx, maxx, miny, maxy;
	float min;
	short currentZoom = rect.origin.tile.zoom;
	
	min = rect.origin.tile.x + rect.origin.offset.x;
	minx = floorf(min);
	maxx = floorf(min + rect.size.width);
	min = rect.origin.tile.y + rect.origin.offset.y;
	miny = floorf(min);
	maxy = floorf(min + rect.size.height);
	
	for(RMTileImage *img in [images allObjects])
	{
		RMTile tile = img.tile;
		short tileZoom = tile.zoom;
		uint32_t x, y;
		int dz, imgDz, rectDz;
		
		/*
		 if (tileZoom > currentZoom) {
		 [self removeTile:tile];
		 continue;
		 }
		 */
		
		x = tile.x;
		y = tile.y;
		dz = tileZoom - currentZoom;
		if(dz < 0)
		{
			// Tile is too large for current zoom level
			imgDz = 0;
			rectDz = -dz;
		}
		else
		{
			// Tile is too small & detailed for current zoom level
			imgDz = dz;
			rectDz = 0;
		}
		if(
		   x >> imgDz > maxx >> rectDz || x >> imgDz < minx >> rectDz ||
		   y >> imgDz > maxy >> rectDz || y >> imgDz < miny >> rectDz
		   ) {
			[self removeTile:tile];
		}
	}
}

@end
