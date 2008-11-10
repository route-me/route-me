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

NSString * const RMMapNewTilesBoundsNotification = @"NewTilesBounds";

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
	
	//NSLog(@"===> TILES LOADED. X:%lf Y:%lf WIDTH:%lf HEIGHT:%lf",newLoadedBounds.origin.x, newLoadedBounds.origin.y, newLoadedBounds.size.width, newLoadedBounds.size.height);
	
	CLLocationCoordinate2DBounds locationBounds  = [content getCoordinateBounds:newLoadedBounds];
	
	//NSLog(@"===> AFTER CONVERSION - BOUNDS: NW Lat: %lf NW Lon:%lf SW Lat:%lf SW Lon:%lf", 
	//	locationBounds.northWest.latitude,locationBounds.northWest.longitude, 
	//	  locationBounds.southEast.latitude, locationBounds.southEast.longitude);
	
	CLLocation *NWLocation = [[CLLocation alloc] initWithLatitude:locationBounds.northWest.latitude longitude:locationBounds.northWest.longitude];
	CLLocation *SELocation = [[CLLocation alloc] initWithLatitude:locationBounds.southEast.latitude longitude:locationBounds.southEast.longitude];
	
	NSArray *keys = [NSArray arrayWithObjects:@"NWBounds", @"SEBounds", nil];
	NSArray *objects = [NSArray arrayWithObjects:NWLocation, SELocation, nil];
	NSDictionary *tilesBounds = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	
	[NWLocation release];
	[SELocation release];
	
	// Send notification
	 [[NSNotificationCenter defaultCenter] postNotificationName:RMMapNewTilesBoundsNotification
	 object:self
	 userInfo:tilesBounds];
	 
	
	
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

- (void)reload
{
	[self clearLoadedBounds];
	[self updateLoadedImages];
}

//-(BOOL) containsRect: (CGRect)bounds
//{
//	return CGRectContainsRect(loadedBounds, bounds);
//}

@end
