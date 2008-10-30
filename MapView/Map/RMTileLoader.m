//
//  TimeImageSet.m
//  Images
//
//  Created by Joseph Gentle on 29/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMTileLoader.h"

#import "RMTileImage.h"
#import "RMTileSource.h"
#import "RMPixel.h"
#import "RMMercatorToScreenProjection.h"
#import "RMFractalTileProjection.h"
#import "RMTileImageSet.h"

#import "RMTileCache.h"

NSString* const RMMapImageRemovedFromScreenNotification = @"RMMapImageRemovedFromScreen";
NSString* const RMMapImageAddedToScreenNotification = @"RMMapImageAddedToScreen";

NSString* const RMSuspendExpensiveOperations = @"RMSuspendExpensiveOperations";
NSString* const RMResumeExpensiveOperations = @"RMResumeExpensiveOperations";

@implementation RMTileLoader

@synthesize loadedBounds, loadedZoom;

-(id) init
{
	if (![self initWithContent: nil])
		return nil;

	return self;
}

-(id) initWithContent: (RMMapContents *)_contents
{
	if (![super init])
		return nil;
	
	content = _contents;
	
	[self clearLoadedBounds];
	loadedTiles.origin.tile = RMTileDummy();
	
	suppressLoading = NO;

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) clearLoadedBounds
{
	loadedBounds = CGRectMake(0, 0, 0, 0);
//	loadedTiles.origin.tile = RMTileDummy();
}
-(BOOL) screenIsLoaded
{
//	RMTileRect targetRect = [content tileBounds];
	BOOL contained = CGRectContainsRect(loadedBounds, [content screenBounds]);
	
	int targetZoom = (int)([[content mercatorToTileProjection] calculateNormalisedZoomFromScale:[content scale]]);

	if (contained == NO)
	{
//		NSLog(@"reassembling because its not contained");
	}
	
	if (targetZoom != loadedZoom)
	{
//		NSLog(@"reassembling because target zoom = %f, loaded zoom = %d", targetZoom, loadedZoom);
	}
	
	return contained && targetZoom == loadedZoom;
}

-(void) updateLoadedImages
{
	if (suppressLoading)
		return;
	
	if ([content mercatorToTileProjection] == nil || [content mercatorToScreenProjection] == nil)
		return;
	
	if ([self screenIsLoaded])
		return;
	
//	NSLog(@"assemble count = %d", [[content imagesOnScreen] count]);
	
	RMTileRect newTileRect = [content tileBounds];
	
	RMTileImageSet *images = [content imagesOnScreen];
	CGRect newLoadedBounds = [images addTiles:newTileRect ToDisplayIn:[content screenBounds]];
	
	if (!RMTileIsDummy(loadedTiles.origin.tile))
		[images removeTiles:loadedTiles];

//	NSLog(@"-> count = %d", [images count]);

	loadedBounds = newLoadedBounds;
	loadedZoom = newTileRect.origin.tile.zoom;
	loadedTiles = newTileRect;
}

- (void)moveBy: (CGSize) delta
{
//	NSLog(@"loadedBounds %f %f %f %f -> ", loadedBounds.origin.x, loadedBounds.origin.y, loadedBounds.size.width, loadedBounds.size.height);
	loadedBounds = RMTranslateCGRectBy(loadedBounds, delta);
//	NSLog(@" -> %f %f %f %f", loadedBounds.origin.x, loadedBounds.origin.y, loadedBounds.size.width, loadedBounds.size.height);
	[self updateLoadedImages];
}

- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center
{
	loadedBounds = RMScaleCGRectAboutPoint(loadedBounds, zoomFactor, center);
	[self updateLoadedImages];
}

- (BOOL) suppressLoading
{
	return suppressLoading;
}

- (void) setSuppressLoading: (BOOL) suppress
{
	suppressLoading = suppress;

	if (suppress == NO)
		[self updateLoadedImages];
}

//-(BOOL) containsRect: (CGRect)bounds
//{
//	return CGRectContainsRect(loadedBounds, bounds);
//}

@end
