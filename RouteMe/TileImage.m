//
//  Tile.m
//  Images
//
//  Created by Joseph Gentle on 13/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TileImage.h"
#import "WebTileImage.h"
#import "FileTileImage.h"

NSString * const MapImageLoadedNotification = @"MapImageLoaded";
NSString * const MapImageLoadingCancelledNotification = @"MapImageLoadingCancelled";

@implementation TileImage

@synthesize screenLocation, tile;

- (id) initBlankTile: (Tile)_tile
{
	if (![super init])
		return nil;
	
	tile = _tile;
	image = nil;
	loadingPriorityCount = 0;
	
	return self;	
}

- (id) initWithTile: (Tile)_tile
{
	if (![self initBlankTile: _tile])
		return nil;

	if ([[self class] isEqual:[TileImage class]])
	{
		[NSException raise:@"Abstract Class Exception" format:@"Error, attempting to instantiate TileImage directly."];
		[self release];
		return nil; 
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tileRemovedFromScreen:)
												 name:MapImageRemovedFromScreenNotification object:self];
	
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

+ (TileImage*) dummyTile: (Tile)tile
{
	return [[[TileImage alloc] initBlankTile:tile] autorelease];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[image release];
	[super dealloc];
}

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
}

- (void)drawInRect:(CGRect)rect
{
	[image drawInRect:rect];
//	[image drawAtPoint:rect.origin];
}

-(void)draw
{
	[self drawInRect:screenLocation];	
}

+ (TileImage*)imageWithTile: (Tile) _tile FromURL: (NSString*)url
{
	return [[[WebTileImage alloc] initWithTile:_tile FromURL:url] autorelease];
}

+ (TileImage*)imageWithTile: (Tile) _tile FromFile: (NSString*)filename
{
	return [[[FileTileImage alloc] initWithTile: _tile FromFile:filename] autorelease];
}

-(void) cancelLoading
{
	[[NSNotificationCenter defaultCenter] postNotificationName:MapImageLoadingCancelledNotification
														object:self];
}
//
//- (void)setImageToData: (NSData*) data
//{
//	image = [[UIImage imageWithData:data] retain];
//}

- (void)setImageToData: (NSData*) data
{
//	CGContextRef context = 
	CGImageRef cgImage = CGImageCreateWithPNGDataProvider(CGDataProviderCreateWithCFData ((CFDataRef)data), NULL, FALSE, kCGRenderingIntentDefault);
	
	image = [[UIImage imageWithCGImage:cgImage] retain];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:MapImageLoadedNotification object:self];
}

- (NSUInteger)hash
{
	return (NSUInteger)TileHash(tile);
}

- (BOOL)isEqual:(id)anObject
{
	if (![anObject isKindOfClass:[TileImage class]])
		return NO;

	return TilesEqual(tile, [(TileImage*)anObject tile]);
}

@end
