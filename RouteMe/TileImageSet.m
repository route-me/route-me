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

@implementation TileImageSet

-(id) initFromRect:(TileRect) rect FromImageSource: (TileSource*)source ToDisplayWithSize:(CGSize)size WithTileDelegate: (id)delegate
{
	if (![self init])
		return nil;
	[self assembleFromRect:rect FromImageSource: source ToDisplayWithSize: size WithTileDelegate: delegate];
	return self;
}

-(id) init
{
	if (![super init])
		return nil;
	dirty = YES;
	images = [[NSMutableSet alloc] init];
	buffer = [[NSMutableSet alloc] init];
	
	return self;
}

-(void) dealloc
{
	NSLog(@"Imageset dealloced");
	[images release];
	[buffer release];
	[super dealloc];
}

-(void) setNeedsRedraw
{/*
	for (TileImage *image in images)
	{
		[image cancelLoading];
	}
	*/
	dirty = YES;
}

-(BOOL) needsRedraw
{
	return dirty;
}

-(void) swapBuffers
{
	NSMutableSet *temp = images;
	images = buffer;
	buffer = temp;
}

-(void) assembleFromRect:(TileRect) rect FromImageSource: (TileSource*)source ToDisplayWithSize:(CGSize)viewSize WithTileDelegate: (id)delegate
{
	[self swapBuffers];
	
	Tile t;
	t.zoom = rect.origin.tile.zoom;
	
	// ... Should be the same as equivalent calculation for height.
	float pixelsPerTile = viewSize.width / rect.size.width;
	
	CGRect screenLocation;
	screenLocation.size.width = pixelsPerTile;
	screenLocation.size.height = pixelsPerTile;
	
	for (t.x = (rect.origin.tile.x); t.x <= (int)(rect.origin.tile.x + (rect.origin.offset.x + rect.size.width)); t.x++)
	{
		for (t.y = (rect.origin.tile.y); t.y <= (int)(rect.origin.tile.y + (rect.origin.offset.y + rect.size.height)); t.y++)
		{
			TileImage *image = [source tileImage:t];
			[image setDelegate:delegate];
			
			screenLocation.origin.x = (-rect.origin.offset.x + (t.x - rect.origin.tile.x)) * pixelsPerTile;
			screenLocation.origin.y = (-rect.origin.offset.y + (t.y - rect.origin.tile.y)) * pixelsPerTile;
			
			image.screenLocation = screenLocation;
			[images addObject:image];
		}
	}
	
	[buffer removeAllObjects];
	
	dirty = NO;
}

-(BOOL) slideBy: (CGSize) amount Within: (CGRect)bounds
{
	BOOL coversTop = NO, coversBottom = NO, coversLeft = NO, coversRight = NO;
	
	for (TileImage *image in images)
	{
		CGRect location = image.screenLocation;
		
		location.origin.x += amount.width;
		location.origin.y += amount.height;
		
		if (location.origin.x <= bounds.origin.x)
			coversLeft = YES;
		if (location.origin.y <= bounds.origin.y)
			coversTop = YES;
		if (location.origin.x + location.size.width >= bounds.origin.x + bounds.size.width)
			coversRight = YES;
		if (location.origin.y + location.size.height >= bounds.origin.y + bounds.size.height)
			coversBottom = YES;
		
		image.screenLocation = location;
	}
	
//	NSLog(@"coversTop = %d, coversBottom = %d, coversLeft = %d, coversRight = %d", coversTop, coversBottom, coversLeft, coversRight);
	
	BOOL fullCoverage = coversTop && coversBottom && coversLeft && coversRight;
	if (fullCoverage == NO)
		dirty = YES;
	
	return fullCoverage;
}

-(void) draw
{
	for (TileImage *image in images)
	{
		[image draw];
	}
}

@end
