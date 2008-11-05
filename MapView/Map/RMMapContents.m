//
//  RMMapContents.m
//  MapView
//
//  Created by Joseph Gentle on 24/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMMapContents.h"

#import "RMFoundation.h"
#import "RMProjection.h"
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

@synthesize boundingMask;

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
	
	self.boundingMask = RMMapMinWidthBound;
//	targetView = view;
	mercatorToScreenProjection = [[RMMercatorToScreenProjection alloc] initFromProjection:[_tileSource projection] ToScreenBounds:[view bounds]];

	tileSource = nil;
	projection = nil;
	mercatorToTileProjection = nil;
	
	renderer = nil;
	imagesOnScreen = nil;
	tileLoader = nil;
	
	layer = [[view layer] retain];
	
	[self setTileSource:_tileSource];
	[self setRenderer:_renderer];
	
	imagesOnScreen = [[RMTileImageSet alloc] initWithDelegate:renderer];
	[imagesOnScreen setTileSource:tileSource];
	tileLoader = [[RMTileLoader alloc] initWithContent:self];
	[tileLoader setSuppressLoading:YES];
	
	[self setZoom:15];
	[self moveToLatLong:latlong];
	
	[tileLoader setSuppressLoading:NO];
	
	// TODO: Make a nice background class
	RMMapLayer *theBackground = [[RMMapLayer alloc] init];
	[self setBackground:theBackground];
	[theBackground release];
	
	RMLayerSet *theOverlay = [[RMLayerSet alloc] initForContents:self];
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
	[projection release];
	[mercatorToTileProjection release];
	[mercatorToScreenProjection release];
	[tileSource release];
	[layer release];
	
	[super dealloc];
}

#pragma mark Forwarded Events

- (void)moveToLatLong: (CLLocationCoordinate2D)latlong
{
	RMXYPoint aPoint = [projection latLongToPoint:latlong];
	[self moveToXYPoint: aPoint];
}
- (void)moveToXYPoint: (RMXYPoint)aPoint
{
	[mercatorToScreenProjection setXYCenter:aPoint];

	[tileLoader reload];
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

- (float)adjustZoomForBoundingMask:(float)zoomFactor
{
	if ( boundingMask ==  RMMapNoMinBound )
		return zoomFactor;
	
	double newScale = self.scale / zoomFactor;
	
	RMXYRect mercatorBounds = [[tileSource projection] bounds];
	
	// Check for MinWidthBound
	if ( boundingMask & RMMapMinWidthBound )
	{
		double newMapContentsWidth = mercatorBounds.size.width / newScale;
		double screenBoundsWidth = [self screenBounds].size.width;
		double mapContentWidth;
		
		if ( newMapContentsWidth < screenBoundsWidth )
		{
			// Calculate new zoom facter so that it does not shrink the map any further. 
			mapContentWidth = mercatorBounds.size.width / self.scale;
			zoomFactor = screenBoundsWidth / mapContentWidth;
			
			newScale = self.scale / zoomFactor;
			newMapContentsWidth = mercatorBounds.size.width / newScale;
		}
		
	}
	
	// Check for MinHeightBound	
	if ( boundingMask & RMMapMinHeightBound )
	{
		double newMapContentsHeight = mercatorBounds.size.height / newScale;
		double screenBoundsHeight = [self screenBounds].size.height;
		double mapContentHeight;
		
		if ( newMapContentsHeight < screenBoundsHeight )
		{
			// Calculate new zoom facter so that it does not shrink the map any further. 
			mapContentHeight = mercatorBounds.size.height / self.scale;
			zoomFactor = screenBoundsHeight / mapContentHeight;
			
			newScale = self.scale / zoomFactor;
			newMapContentsHeight = mercatorBounds.size.height / newScale;
		}
		
	}
	
	//[self adjustMapPlacementWithScale:newScale];
	
	return zoomFactor;
}

// This currently is not called because it does not handle the case when the map is continous or not continous.  At a certain scale
// you can continuously move to the west or east until you get to a certain scale level that simply shows the entire world.
- (void)adjustMapPlacementWithScale:(float)aScale
{
	CGSize		adjustmentDelta = {0.0, 0.0};
	RMLatLong	rightEdgeLatLong = {0, 180};
	RMLatLong	leftEdgeLatLong = {0,- 180};
	
	CGPoint		rightEdge = [self latLongToPixel:rightEdgeLatLong withScale:aScale];
	CGPoint		leftEdge = [self latLongToPixel:leftEdgeLatLong withScale:aScale];
	//CGPoint		topEdge = [self latLongToPixel:myLatLong withScale:aScale];
	//CGPoint		bottomEdge = [self latLongToPixel:myLatLong withScale:aScale];
	
	CGRect		containerBounds = [self screenBounds];

	if ( rightEdge.x < containerBounds.size.width ) 
	{
		adjustmentDelta.width = containerBounds.size.width - rightEdge.x;
		[self moveBy:adjustmentDelta];
	}
	
	if ( leftEdge.x > containerBounds.origin.x ) 
	{
		adjustmentDelta.width = containerBounds.origin.x - leftEdge.x;
		[self moveBy:adjustmentDelta];
	}
	
	
}

- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) pivot
{
	zoomFactor = [self adjustZoomForBoundingMask:zoomFactor];
	

	[mercatorToScreenProjection zoomScreenByFactor:zoomFactor near:pivot];
	[imagesOnScreen zoomByFactor:zoomFactor near:pivot];
	[tileLoader zoomByFactor:zoomFactor near:pivot];
	[overlay zoomByFactor:zoomFactor near:pivot];
	[renderer setNeedsDisplay];
}

- (void) drawRect: (CGRect) aRect
{
	[renderer drawRect:aRect];
}

#pragma mark Properties

- (void) setTileSource: (id<RMTileSource>)newTileSource
{
	if (tileSource == newTileSource)
		return;

	newTileSource = [RMCachedTileSource cachedTileSourceWithSource:newTileSource];
	
	[tileSource release];
	tileSource = [newTileSource retain];
	
	[projection release];
	projection = [[tileSource projection] retain];
	
	[mercatorToTileProjection release];
	mercatorToTileProjection = [[tileSource mercatorToTileProjection] retain];
	
	[imagesOnScreen setTileSource:tileSource];

	[tileLoader reload];
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
		[layer insertSublayer:[renderer layer] atIndex: 0];
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

- (void) setOverlay: (RMLayerSet*) aLayer
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

- (RMLayerSet *)overlay
{
	return [[overlay retain] autorelease];
}

- (CLLocationCoordinate2D) mapCenter
{
	RMXYPoint aPoint = [mercatorToScreenProjection XYCenter];
	return [projection pointToLatLong:aPoint];
}

-(void) setMapCenter: (CLLocationCoordinate2D) center
{
	[self moveToLatLong:center];
}

-(RMXYRect) XYBounds
{
	return [mercatorToScreenProjection XYBounds];
}
-(void) setXYBounds: (RMXYRect) boundsRect
{
	[mercatorToScreenProjection setXYBounds:boundsRect];
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

-(RMProjection*) projection
{
	return [[projection retain] autorelease];
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

- (CGPoint)latLongToPixel:(CLLocationCoordinate2D)latlong
{	
	return [mercatorToScreenProjection projectXYPoint:[projection latLongToPoint:latlong]];
}

- (CGPoint)latLongToPixel:(CLLocationCoordinate2D)latlong withScale:(float)aScale
{	
	return [mercatorToScreenProjection projectXYPoint:[projection latLongToPoint:latlong] withScale:aScale];
}

- (CLLocationCoordinate2D)pixelToLatLong:(CGPoint)aPixel
{
	return [projection pointToLatLong:[mercatorToScreenProjection projectScreenPointToXY:aPixel]];
}

- (CLLocationCoordinate2D)pixelToLatLong:(CGPoint)aPixel withScale:(float)aScale
{
	return [projection pointToLatLong:[mercatorToScreenProjection projectScreenPointToXY:aPixel withScale:aScale]];
}


#pragma mark Zoom With Bounds
- (void)zoomWithLatLngBoundsNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)sw
{
	if(ne.latitude == sw.latitude && ne.longitude == sw.longitude)//There are no bounds, probably only one marker.
	{
		RMXYRect zoomRect;
		RMXYPoint myOrigin = [projection latLongToPoint:sw];
		//Default is with scale = 2.0 mercators/pixel
		zoomRect.size.width = [self screenBounds].size.width * 2.0;
		zoomRect.size.height = [self screenBounds].size.height * 2.0;
		myOrigin.x = myOrigin.x - (zoomRect.size.width / 2);
		myOrigin.y = myOrigin.y - (zoomRect.size.height / 2);
		zoomRect.origin = myOrigin;
		[self zoomWithRMMercatorRectBounds:zoomRect];
	}
	else
	{
		//convert ne/sw into RMMercatorRect and call zoomWithBounds
		float pixelBuffer = 50;
		CLLocationCoordinate2D latLngBounds;
		latLngBounds.longitude = ne.longitude - sw.longitude;
		latLngBounds.latitude = ne.latitude - sw.latitude;
		CLLocationCoordinate2D midpoint;
		midpoint.latitude = (ne.latitude + sw.latitude) / 2;
		midpoint.longitude = (ne.longitude + sw.longitude) / 2;
		RMXYPoint myOrigin = [projection latLongToPoint:midpoint];
		RMXYPoint myPoint = [projection latLongToPoint:latLngBounds];
		//Create the new zoom layout
		RMXYRect zoomRect;
		//Default is with scale = 2.0 mercators/pixel
		zoomRect.size.width = [self screenBounds].size.width * 2.0;
		zoomRect.size.height = [self screenBounds].size.height * 2.0;
		if((myPoint.x / ([self screenBounds].size.width)) < (myPoint.y / ([self screenBounds].size.height)))
		{
			if((myPoint.y / ([self screenBounds].size.height - pixelBuffer)) > 1)
			{
				zoomRect.size.width = [self screenBounds].size.width * (myPoint.y / ([self screenBounds].size.height - pixelBuffer));
				zoomRect.size.height = [self screenBounds].size.height * (myPoint.y / ([self screenBounds].size.height - pixelBuffer));
			}
		}
		else
		{
			if((myPoint.x / ([self screenBounds].size.width - pixelBuffer)) > 1)
			{
				zoomRect.size.width = [self screenBounds].size.width * (myPoint.x / ([self screenBounds].size.width - pixelBuffer));
				zoomRect.size.height = [self screenBounds].size.height * (myPoint.x / ([self screenBounds].size.width - pixelBuffer));
			}
		}
		myOrigin.x = myOrigin.x - (zoomRect.size.width / 2);
		myOrigin.y = myOrigin.y - (zoomRect.size.height / 2);
		NSLog(@"Origin is calculated at: %f, %f", [projection pointToLatLong:myOrigin].latitude, [projection pointToLatLong:myOrigin].longitude);
		/*It gets all messed up if our origin is lower than the lowest place on the map, so we check.
		 if(myOrigin.y < -19971868.880409)
		 {
		 myOrigin.y = -19971868.880409;
		 }*/
		zoomRect.origin = myOrigin;
		[self zoomWithRMMercatorRectBounds:zoomRect];
	}
}


- (void)zoomWithRMMercatorRectBounds:(RMXYRect)bounds
{
	[self setXYBounds:bounds];
	[overlay correctPositionOfAllSublayers];
	[tileLoader clearLoadedBounds];
	[tileLoader updateLoadedImages];
	[renderer setNeedsDisplay];
	
}


#pragma mark Markers and overlays

// Move overlays stuff here - at the moment overlay stuff is above...

- (void) addMarker: (RMMarker*)marker
{
	[overlay addSublayer:marker];
}

- (void) addMarker: (RMMarker*)marker AtLatLong:(CLLocationCoordinate2D)point
{
	[marker setLocation:[projection latLongToPoint:point]];
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

- (NSArray *)getMarkers
{
	return [overlay sublayers];
}

- (void) removeMarker:(RMMarker *)marker
{
	[marker removeFromSuperlayer];
}

@end
