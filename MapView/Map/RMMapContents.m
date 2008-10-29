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
#import "RMCachedTileSource.h"

#import "RMLayerSet.h"

#import "RMMarker.h"

@implementation RMMapContents

#pragma mark Initialisation
- (id) initForView: (UIView*) view
{
	id<RMTileSource> _tileSource = [[RMOpenStreetMapsSource alloc] init];
	RMMapRenderer *_renderer = [[RMCoreAnimationRenderer alloc] initWithContent:self];
	
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
	
	layer = [[view layer] retain];
	
	[self setTileSource:_tileSource];
	[self setRenderer:_renderer];
	
	imagesOnScreen = [[RMTileImageSet alloc] initWithDelegate:renderer];
	[imagesOnScreen setTileSource:[RMCachedTileSource cachedTileSourceWithSource:tileSource]];
	tileLoader = [[RMTileLoader alloc] initWithContent:self];
	[tileLoader setSuppressLoading:YES];
	
	[self setZoom:15];
	[self moveToLatLong:latlong];
	
	[tileLoader setSuppressLoading:NO];
	
	// TODO: Make a nice background class
	RMMapLayer *theBackground = [[RMMapLayer alloc] init];
	[self setBackground:theBackground];
	[theBackground release];
	
	RMMapLayer *theOverlay = [[RMLayerSet alloc] initForContents:self];
	[self setOverlay:theOverlay];
	[theOverlay release];
	
	[view setNeedsDisplay];
	
	NSLog(@"Map contents initialised. view: %@ tileSource %@ renderer %@", view, tileSource, renderer);
	
	return self;
}

-(void) dealloc
{
	[renderer release];
	[tileSource release];
	[tileLoader release];
	[latLongToMercatorProjection release];
	[mercatorToTileProjection release];
	[mercatorToScreenProjection release];
	[tileSource release];
	[layer release];
	
	[super dealloc];
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
	
//	[imagesOnScreen removeAllTiles];
	[tileLoader clearLoadedBounds];
	
	[tileLoader updateLoadedImages];
	[renderer setNeedsDisplay];
}

- (void)moveBy: (CGSize) delta
{
	[mercatorToScreenProjection moveScreenBy:delta];
	[imagesOnScreen moveBy:delta];
	[tileLoader moveBy:delta];
	[overlay moveBy:delta];
	[renderer setNeedsDisplay];
}
- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) pivot
{
	[mercatorToScreenProjection zoomScreenByFactor:zoomFactor Near:pivot];
	[imagesOnScreen zoomByFactor:zoomFactor Near:pivot];
	[tileLoader zoomByFactor:zoomFactor Near:pivot];
	[overlay zoomByFactor:zoomFactor Near:pivot];
	[renderer setNeedsDisplay];
}

- (void) drawRect: (CGRect) rect
{
	[renderer drawRect:rect];
}

#pragma mark Properties

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

- (id<RMTileSource>) tileSource
{
	return [[tileSource retain] autorelease];
}

- (void) setRenderer: (RMMapRenderer*) newRenderer
{
	if (renderer == newRenderer)
		return;
	
	[[renderer layer] removeFromSuperlayer];
	[renderer release];
	
	renderer = [newRenderer retain];
	
	//	CGRect rect = [self screenBounds];
	//	NSLog(@"%f %f %f %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
	[[renderer layer] setFrame:[self screenBounds]];
	
	if (background != nil)
		[layer insertSublayer:[renderer layer] above:background];
	else if (overlay != nil)
		[layer insertSublayer:[renderer layer] below:overlay];
	else
		[layer addSublayer:[renderer layer]];
}

- (RMMapRenderer *)renderer
{
	return [[renderer retain] autorelease];
}

- (void) setBackground: (RMMapLayer*) aLayer
{
	if (background != nil)
	{
		[background release];
		[background removeFromSuperlayer];		
	}
	
	background = [aLayer retain];
	background.frame = [self screenBounds];
	
	if ([renderer layer] != nil)
		[layer insertSublayer:background below:[renderer layer]];
	else if (overlay != nil)
		[layer insertSublayer:background below:overlay];
	else
		[layer addSublayer:background];
}

- (RMMapLayer *)background
{
	return [[background retain] autorelease];
}

- (void) setOverlay: (RMMapLayer*) aLayer
{
	if (overlay != nil)
	{
		[overlay release];
		[overlay removeFromSuperlayer];		
	}
	
	overlay = [aLayer retain];
	overlay.frame = [self screenBounds];
	
	if ([renderer layer] != nil)
		[layer insertSublayer:overlay above:[renderer layer]];
	else if (background != nil)
		[layer insertSublayer:overlay above:background];
	else
		[layer addSublayer:overlay];
	
	/* Test to make sure the overlay is working.
	CALayer *testLayer = [[CALayer alloc] init];
	
	[testLayer setFrame:CGRectMake(100, 100, 200, 200)];
	[testLayer setBackgroundColor:[[UIColor brownColor] CGColor]];
	
	NSLog(@"added test layer");
	[overlay addSublayer:testLayer];*/
}

- (RMMapLayer *)overlay
{
	return [[overlay retain] autorelease];
}

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
	if (mercatorToScreenProjection != nil)
		return [mercatorToScreenProjection screenBounds];
	else
		return CGRectMake(0, 0, 0, 0);
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

- (CALayer *)layer
{
	return [[layer retain] autorelease];
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

#pragma mark LatLng/Pixel translation functions

- (CGPoint)latLngToPixel:(CLLocationCoordinate2D)latlong
{	
	return [mercatorToScreenProjection projectMercatorPoint:[latLongToMercatorProjection projectLatLongToMercator:latlong]];
}
- (CLLocationCoordinate2D)pixelToLatLng:(CGPoint)pixel
{
	return [latLongToMercatorProjection projectMercatorToLatLong:[mercatorToScreenProjection projectScreenPointToMercator:pixel]];
}

#pragma mark Markers and overlays

// Move overlays stuff here - at the moment overlay stuff is above...

- (void) addMarker: (RMMarker*)marker
{
	[overlay addSublayer:marker];
}

- (void) addMarker: (RMMarker*)marker AtLatLong:(CLLocationCoordinate2D)point
{
	[marker setLocation:[latLongToMercatorProjection projectLatLongToMercator:point]];
	[self addMarker: marker];
}

- (void) addDefaultMarkerAt: (CLLocationCoordinate2D)point
{
	RMMarker *marker = [[RMMarker alloc] initWithKey:RMMarkerRedKey];
	[self addMarker:marker AtLatLong:point];
	[marker release];
}

- (void) removeMarkers
{
	overlay.sublayers = [NSArray arrayWithObjects:nil]; 
}

@end
