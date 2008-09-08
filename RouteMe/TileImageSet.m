//
//  TimeImageSet.m
//  Images
//
//  Created by Joseph Gentle on 29/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TileImageSet.h"

#import "TileImage.h"
#import "TileSource.h"
#import "MathUtils.h"

@implementation TileImageSet

@synthesize loadedBounds, loadedZoom, nudgeTileSize;

-(id) initFromRect:(TileRect) rect FromImageSource: (id<TileSource>)source ToDisplayIn:(CGRect)bounds WithTileDelegate: (id)delegate
{
	if (![self init])
		return nil;
	[self assembleFromRect:rect FromImageSource: source ToDisplayIn:bounds WithTileDelegate: delegate];
	return self;
}

-(id) init
{
	if (![super init])
		return nil;
//	dirty = YES;
	images = [[NSMutableSet alloc] init];
	buffer = [[NSMutableSet alloc] init];
	loadedBounds = CGRectMake(0, 0, 0, 0);
	nudgeTileSize = YES;
	
	return self;
}

-(void) dealloc
{
	NSLog(@"Imageset dealloced");
	[images release];
	[buffer release];
	[super dealloc];
}
/*
-(void) setNeedsRedraw
{
	dirty = YES;
}

-(BOOL) needsRedraw
{
	return dirty;
}*/

-(void) swapBuffers
{
	NSMutableSet *temp = images;
	images = buffer;
	buffer = temp;
}

-(void) assembleFromRect:(TileRect) rect FromImageSource: (id<TileSource>)source ToDisplayIn:(CGRect)bounds WithTileDelegate: (id)delegate
{
	[self swapBuffers];
	
	Tile t;
	t.zoom = rect.origin.tile.zoom;
	
	// ... Should be the same as equivalent calculation for height.
	float pixelsPerTile = bounds.size.width / rect.size.width;
	
	CGRect screenLocation;
	screenLocation.size.width = pixelsPerTile;
	screenLocation.size.height = pixelsPerTile;
	
	// Corrects a bug in quartz's resizing code
	if (nudgeTileSize)
	{
		screenLocation.size.width += 0.5;
		screenLocation.size.height += 0.5;
	}
	
	for (t.x = (rect.origin.tile.x); t.x <= (rect.origin.tile.x + (int)(rect.origin.offset.x + rect.size.width)); t.x++)
	{
		for (t.y = (rect.origin.tile.y); t.y <= (rect.origin.tile.y + (int)(rect.origin.offset.y + rect.size.height)); t.y++)
		{
			TileImage *image = [source tileImage:t];
			[image increaseLoadingPriority];
			[image setDelegate:delegate];
			
			screenLocation.origin.x = bounds.origin.x + (t.x - (rect.origin.offset.x + rect.origin.tile.x)) * pixelsPerTile;
			screenLocation.origin.y = bounds.origin.y + (t.y - (rect.origin.offset.y + rect.origin.tile.y)) * pixelsPerTile;
			
//			NSLog(@"screenLocation from %f to %f", screenLocation.origin.x, screenLocation.origin.x + screenLocation.size.width);
			
			image.screenLocation = screenLocation;
			[images addObject:image];
		}
	}
	
	loadedBounds.origin.x = bounds.origin.x - (rect.origin.offset.x * pixelsPerTile);
	loadedBounds.origin.y = bounds.origin.y - (rect.origin.offset.y * pixelsPerTile);	
	loadedBounds.size.width = (1 + (int)(rect.size.width + rect.origin.offset.x)) * pixelsPerTile;
	loadedBounds.size.height = (1 + (int)(rect.size.height + rect.origin.offset.x)) * pixelsPerTile;
	loadedZoom = rect.origin.tile.zoom;
	
	for (TileImage *image in buffer)
	{
		[image decreaseLoadingPriority];
	}
	[buffer removeAllObjects];
	
//	dirty = NO;
}

- (void)moveBy: (CGSize) delta
{
	for (TileImage *image in images)
	{
		CGRect location = image.screenLocation;
		location = TranslateCGRectBy(location, delta);
		image.screenLocation = location;
	}
	
	loadedBounds = TranslateCGRectBy(loadedBounds, delta);
}

- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center
{
	for (TileImage *image in images)
	{
		CGRect location = image.screenLocation;
		location = ScaleCGRectAboutPoint(location, zoomFactor, center);
		image.screenLocation = location;
	}
	
	loadedBounds = ScaleCGRectAboutPoint(loadedBounds, zoomFactor, center);
}

-(BOOL) containsRect: (CGRect)bounds
{
	return CGRectContainsRect(loadedBounds, bounds);
}

-(void) draw
{
	for (TileImage *image in images)
	{
		[image draw];
	}
}

@end
