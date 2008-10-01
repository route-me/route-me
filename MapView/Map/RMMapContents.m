//
//  RMMapContents.m
//  MapView
//
//  Created by Joseph Gentle on 24/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMMapContents.h"

#import "RMLatLong.h"
#import "RMMercator.h"
#import "RMLatLongToMercatorProjection.h"
#import "RMMercatorToScreenProjection.h"
#import "RMMercatorToTileProjection.h"

#import "RMTileSource.h"
#import "RMTileLoader.h"
#import "RMTileImageSet.h"

#import "RMOpenStreetMapsSource.h"
#import "RMCoreAnimationRenderer.h"
#import "RMQuartzRenderer.h"
#import "RMCachedTileSource.h"

@implementation RMMapContents

#pragma mark Initialisation
- (id) initForView: (UIView*) view
{
	id<RMTileSource> _tileSource = [[RMOpenStreetMapsSource alloc] init];
	RMMapRenderer *_renderer = [[RMCoreAnimationRenderer alloc] initForView:view WithContent:self];
//	RMMapRenderer *_renderer = [[RMQuartzRenderer alloc] initForView:view WithContent:self];
	
	CLLocationCoordinate2D here;
	here.latitude = -33.9464;
	here.longitude = 151.2381;
//	here.latitude = 65.146;
//	here.longitude = 189.9;
	
	id mapContents = [self initForView:view WithTileSource:_tileSource WithRenderer:_renderer LookingAt:here];
	
	[_tileSource release];
	[_renderer release];
	
	return mapContents;
}

- (void) setTileSource: (id<RMTileSource>)newTileSource
{
	[tileSource release];
	tileSource = [newTileSource retain];
	
	[latLongToMercatorProjection release];
	latLongToMercatorProjection = [[tileSource latLongToMercatorProjection] retain];
	
	[mercatorToTileProjection release];
	mercatorToTileProjection = [[tileSource mercatorToTileProjection] retain];
	
	[imagesOnScreen setTileSource:tileSource];
}

- (void) setRenderer: (RMMapRenderer*) newRenderer
{
	[renderer release];
	renderer = [newRenderer retain];
}

- (id) initForView: (UIView*) view WithTileSource: (id<RMTileSource>)_tileSource WithRenderer: (RMMapRenderer*)_renderer LookingAt:(CLLocationCoordinate2D)latlong
{
	if (![super init])
		return nil;
	
//	targetView = view;
	mercatorToScreenProjection = [[RMMercatorToScreenProjection alloc] initWithScreenBounds:[view bounds]];

	tileSource = nil;
	latLongToMercatorProjection = nil;
	mercatorToTileProjection = nil;
	
	renderer = nil;
	imagesOnScreen = nil;
	tileLoader = nil;
	
	[self setTileSource:_tileSource];
	[self setRenderer:_renderer];
	
	imagesOnScreen = [[RMTileImageSet alloc] initWithDelegate:renderer];
	[imagesOnScreen setTileSource:[RMCachedTileSource cachedTileSourceWithSource:tileSource]];
	tileLoader = [[RMTileLoader alloc] initWithContent:self];
	
	[self setZoom:5];
	[self moveToLatLong:latlong];
	[view setNeedsDisplay];
	
	NSLog(@"Map contents initialised. view: %@ tileSource %@ renderer %@", view, tileSource, renderer);
	
	return self;
}

#pragma mark Forwarded Events

- (void)moveToLatLong: (CLLocationCoordinate2D)latlong
{
	RMMercatorPoint mercator = [latLongToMercatorProjection projectLatLongToMercator:latlong];
	[self moveToMercator: mercator];
}
- (void)moveToMercator: (RMMercatorPoint)mercator
{
	[mercatorToScreenProjection setMercatorCenter:mercator];
	
	[imagesOnScreen removeAllTiles];
	[tileLoader clearLoadedBounds];
	
	[tileLoader updateLoadedImages];
	[renderer setNeedsDisplay];
}

- (void)moveBy: (CGSize) delta
{
	[mercatorToScreenProjection moveScreenBy:delta];
	[imagesOnScreen moveBy:delta];
	[tileLoader moveBy:delta];
	[renderer setNeedsDisplay];
}
- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) pivot
{
	[mercatorToScreenProjection zoomScreenByFactor:zoomFactor Near:pivot];
	[imagesOnScreen zoomByFactor:zoomFactor Near:pivot];
	[tileLoader zoomByFactor:zoomFactor Near:pivot];
	[renderer setNeedsDisplay];
}

- (void) drawRect: (CGRect) rect
{
	[renderer drawRect:rect];
}

#pragma mark Properties

- (CLLocationCoordinate2D) mapCenter
{
	RMMercatorPoint mercCenter = [mercatorToScreenProjection mercatorCenter];
	return [latLongToMercatorProjection projectMercatorToLatLong:mercCenter];
}

-(void) setMapCenter: (CLLocationCoordinate2D) center
{
	[self moveToLatLong:center];
}

-(RMMercatorRect) mercatorBounds
{
	return [mercatorToScreenProjection mercatorBounds];
}
-(void) setMercatorBounds: (RMMercatorRect) bounds
{
	[mercatorToScreenProjection setMercatorBounds:bounds];
}

-(RMTileRect) tileBounds
{
	return [mercatorToTileProjection project: mercatorToScreenProjection];
}

-(CGRect) screenBounds
{
	return [mercatorToScreenProjection screenBounds];
}

-(float) scale
{
	return [mercatorToScreenProjection scale];
}

-(void) setScale: (float) scale
{
	[mercatorToScreenProjection setScale:scale];	
	[tileLoader updateLoadedImages];
	[renderer setNeedsDisplay];
}

-(float) zoom
{
	return [mercatorToTileProjection calculateZoomFromScale:[mercatorToScreenProjection scale]];
}
-(void) setZoom: (float) zoom
{
	float scale = [mercatorToTileProjection calculateScaleFromZoom:zoom];
	[self setScale:scale];	
}

-(RMTileImageSet*) imagesOnScreen
{
	return [[imagesOnScreen retain] autorelease];
}

-(RMLatLongToMercatorProjection*) latLongToMercatorProjection
{
	return [[latLongToMercatorProjection retain] autorelease];
}
-(id<RMMercatorToTileProjection>) mercatorToTileProjection
{
	return [[mercatorToTileProjection retain] autorelease];
}
-(RMMercatorToScreenProjection*) mercatorToScreenProjection
{
	return [[mercatorToScreenProjection retain] autorelease];
}

-(id<RMTileSource>) tileSource
{
	return [[tileSource retain] autorelease];
}

static BOOL _performExpensiveOperations = YES;
+ (BOOL) performExpensiveOperations
{
	return _performExpensiveOperations;
}
+ (void) setPerformExpensiveOperations: (BOOL)p
{
	if (p == _performExpensiveOperations)
		return;
	
	_performExpensiveOperations = p;

	if (p)
		[[NSNotificationCenter defaultCenter] postNotificationName:RMResumeExpensiveOperations object:self];
	else
		[[NSNotificationCenter defaultCenter] postNotificationName:RMSuspendExpensiveOperations object:self];
}

@end
