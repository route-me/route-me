//
//  TileImageSet.m
//  RouteMe
//
//  Created by Joseph Gentle on 9/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMTileImageSet.h"
#import "RMTileImage.h"
#import "RMPixel.h"
#import "RMTileSource.h"

// For notification strings
#import "RMTileLoader.h"

#import "RMMercatorToTileProjection.h"

@implementation RMTileImageSet

@synthesize delegate, tileSource;

-(id) initWithDelegate: (id) _delegate
{
	if (![super init])
		return nil;
	
	tileSource = nil;
	self.delegate = _delegate;
	images = [[NSCountedSet alloc] init];
	return self;
}

-(void) dealloc
{
	[self removeAllTiles];
	[tileSource release];
	[images release];
	[super dealloc];
}

-(void) removeTile: (RMTile) tile
{
	if (RMTileIsDummy(tile))
	{
		NSLog(@"attempted to remove dummy tile...??");
		return;
	}
	
	RMTileImage *dummyTile = [RMTileImage dummyTile:tile];
	if ([images countForObject:dummyTile] == 1)
	{
		if ([delegate respondsToSelector: @selector(tileRemoved:)])
		{
			[delegate tileRemoved:tile];
		}

		[[NSNotificationCenter defaultCenter] postNotificationName:RMMapImageRemovedFromScreenNotification object:[self imageWithTile:tile]];
	}

	[images removeObject:dummyTile];
}

-(void) removeTiles: (RMTileRect)rect
{	
	RMTileRect roundedRect = RMTileRectRound(rect);
	// The number of tiles we'll load in the vertical and horizontal directions
	int tileRegionWidth = (int)roundedRect.size.width;
	int tileRegionHeight =  (int)roundedRect.size.height;
	
	RMTile t;
	t.zoom = rect.origin.tile.zoom;
	
	id<RMMercatorToTileProjection> proj = [tileSource mercatorToTileProjection];
	
	for (t.x = roundedRect.origin.tile.x; t.x < roundedRect.origin.tile.x + tileRegionWidth; t.x++)
	{
		for (t.y = (roundedRect.origin.tile.y); t.y <= roundedRect.origin.tile.y + tileRegionHeight; t.y++)
		{
			RMTile normalisedTile = [proj normaliseTile: t];
			if (RMTileIsDummy(normalisedTile))
			{
				continue;				
			}
			
			[self removeTile:normalisedTile];
		}
	}
}


-(void) removeAllTiles
{
	NSArray * imagelist = [images allObjects];
	for (RMTileImage * img in imagelist) {
    NSInteger count = [images countForObject:img];
		for (int i = 0; i < count; i++)
			[self removeTile: img.tile];
	}
}

/* Untested.
 -(BOOL) hasTile: (Tile) tile
 {
 NSEnumerator *enumerator = [images objectEnumerator];
 TileImage *object;
 
 while ((object = [enumerator nextObject])) {
 if (TilesEqual(tile, [object tile]))
 return YES;
 }
 
 return NO;
 }*/

-(void) addTile: (RMTile) tile WithImage: (RMTileImage *)image At: (CGRect) screenLocation
{
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
	//	NSLog(@"addTile: %d %d", tile.x, tile.y);
	
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
//	NSLog(@"addTiles: %d %d - %f %f", rect.origin.tile.x, rect.origin.tile.y, rect.size.width, rect.size.height);
	
	RMTile t;
	t.zoom = rect.origin.tile.zoom;
	
	// ... Should be the same as equivalent calculation for height.
	float pixelsPerTile = bounds.size.width / rect.size.width;
	
	CGRect screenLocation;
	screenLocation.size.width = pixelsPerTile;
	screenLocation.size.height = pixelsPerTile;
	
	RMTileRect roundedRect = RMTileRectRound(rect);
	// The number of tiles we'll load in the vertical and horizontal directions
	int tileRegionWidth = (int)roundedRect.size.width;
	int tileRegionHeight = (int)roundedRect.size.height;
	
	id<RMMercatorToTileProjection> proj = [tileSource mercatorToTileProjection];
		
	for (t.x = roundedRect.origin.tile.x; t.x < roundedRect.origin.tile.x + tileRegionWidth; t.x++)
	{
		for (t.y = (roundedRect.origin.tile.y); t.y <= roundedRect.origin.tile.y + tileRegionHeight; t.y++)
		{
			RMTile normalisedTile = [proj normaliseTile: t];
			if (RMTileIsDummy(normalisedTile))
				continue;
			
			screenLocation.origin.x = bounds.origin.x + (t.x - (rect.origin.offset.x + rect.origin.tile.x)) * pixelsPerTile;
			screenLocation.origin.y = bounds.origin.y + (t.y - (rect.origin.offset.y + rect.origin.tile.y)) * pixelsPerTile;
			
			[self addTile:normalisedTile At:screenLocation];
		}
	}
	
	// Now we translate the loaded region back into screen space for loadedBounds.
	CGRect newLoadedBounds;
	newLoadedBounds.origin.x = bounds.origin.x - (rect.origin.offset.x * pixelsPerTile);
	newLoadedBounds.origin.y = bounds.origin.y - (rect.origin.offset.y * pixelsPerTile);	
	newLoadedBounds.size.width = tileRegionWidth * pixelsPerTile;
	newLoadedBounds.size.height = tileRegionHeight * pixelsPerTile;
	return newLoadedBounds;
}

-(RMTileImage*) imageWithTile: (RMTile) tile
{
	NSEnumerator *enumerator = [images objectEnumerator];
	RMTileImage *object;
	
	while ((object = [enumerator nextObject]))
	{
		if (RMTilesEqual(tile, [object tile]))
			return object;
	}
	
	return nil;
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

- (void) drawRect:(CGRect) rect
{
	for (RMTileImage *image in images)
	{
		[image draw];
	}
}

- (void) printDebuggingInformation
{
	float biggestSeamRight = 0.0f;
	float biggestSeamDown = 0.0f;
	
	for (RMTileImage *image in images)
	{
		CGRect location = [image screenLocation];
/*		NSLog(@"Image at %f, %f %f %f",
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
	
	NSLog(@"Biggest seam right: %f  down: %f", biggestSeamRight, biggestSeamDown);
}

- (void)cancelLoading
{
	for (RMTileImage *image in images)
	{
		[image cancelLoading];
	}
}


@end
