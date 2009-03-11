//
//  RMMapContents.m
//
// Copyright (c) 2008, Route-Me Contributors
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
#import "RMMarkerManager.h"

#import "RMMarker.h"


@interface RMMapContents (PrivateMethods)
- (void)animatedZoomStep:(NSTimer *)timer;
@end

@implementation RMMapContents (Internal)
	BOOL delegateHasRegionUpdate;
@end

@implementation RMMapContents

@synthesize boundingMask;
@synthesize minZoom;
@synthesize maxZoom;
@synthesize markerManager;

#pragma mark Initialisation

- (id) initForView: (UIView*) view
{	
	CLLocationCoordinate2D here;
	here.latitude = -33.858771;
	here.longitude = 151.201596;

	return [self initForView:view WithLocation: here];
}

- (id) initForView: (UIView*) view WithLocation:(CLLocationCoordinate2D)latlong
{
	id<RMTileSource> _tileSource = [[RMOpenStreetMapsSource alloc] init];
	RMMapRenderer *_renderer = [[RMCoreAnimationRenderer alloc] initWithContent:self];
		
	id mapContents = [self initForView:view WithTileSource:_tileSource WithRenderer:_renderer LookingAt:latlong];
	[_tileSource release];
	[_renderer release];
	
	return mapContents;
}


- (id) initForView: (UIView*) view WithTileSource: (id<RMTileSource>)_tileSource WithRenderer: (RMMapRenderer*)_renderer LookingAt:(CLLocationCoordinate2D)latlong
{
	if (![super init])
		return nil;
	
	[self setMaxZoom:50.0];
	
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
	
	[self setZoom:13];
	[self moveToLatLong:latlong];
	
	[tileLoader setSuppressLoading:NO];
	
	// TODO: Make a nice background class
	RMMapLayer *theBackground = [[RMMapLayer alloc] init];
	[self setBackground:theBackground];
	[theBackground release];
	
	RMLayerSet *theOverlay = [[RMLayerSet alloc] initForContents:self];
	[self setOverlay:theOverlay];
	[theOverlay release];
	
	markerManager = [[RMMarkerManager alloc] initWithContents:self];
	
	[view setNeedsDisplay];
	
	RMLog(@"Map contents initialised. view: %@ tileSource %@ renderer %@", view, tileSource, renderer);
	
	return self;
}

- (void)setFrame:(CGRect)frame
{
  CGRect bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
  [mercatorToScreenProjection setScreenBounds:bounds];
  background.frame = bounds;
  layer.frame = frame;
  overlay.frame = bounds;
  [tileLoader clearLoadedBounds];
  [tileLoader updateLoadedImages];
  [renderer setFrame:frame];
  [overlay correctPositionOfAllSublayers];
}

-(void) dealloc
{
  [imagesOnScreen cancelLoading];
	[self setRenderer:nil];
	[imagesOnScreen release];
	[tileLoader release];
	[projection release];
	[mercatorToTileProjection release];
	[mercatorToScreenProjection release];
	[tileSource release];
	[self setOverlay:nil];
	[self setBackground:nil];
	[layer release];
	[markerManager release];
	RMLog(@"mapcontents dealloced");
	[super dealloc];
}

- (void) didReceiveMemoryWarning
{
	[tileSource didReceiveMemoryWarning];
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
	[overlay correctPositionOfAllSublayers];
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

- (void)setZoomBounds:(float)aMinZoom maxZoom:(float)aMaxZoom
{
	[self setMinZoom: aMinZoom];
	[self setMaxZoom: aMaxZoom];
}

- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) pivot
{
	//[self zoomByFactor:zoomFactor near:pivot animated:NO];
	
	zoomFactor = [self adjustZoomForBoundingMask:zoomFactor];
	//RMLog(@"Zoom Factor: %lf for Zoom:%f", zoomFactor, [self zoom]);
	
	// pre-calculate zoom so we can tell if we want to perform it
	float newZoom = [mercatorToTileProjection  
					 calculateZoomFromScale:self.scale/zoomFactor];
	
	if ((newZoom > minZoom) && (newZoom < maxZoom))
	{
		[mercatorToScreenProjection zoomScreenByFactor:zoomFactor near:pivot];
		[imagesOnScreen zoomByFactor:zoomFactor near:pivot];
		[tileLoader zoomByFactor:zoomFactor near:pivot];
		[overlay zoomByFactor:zoomFactor near:pivot];
		[renderer setNeedsDisplay];
	} 
}


- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) pivot animated:(BOOL) animated
{
	[self zoomByFactor:zoomFactor near:pivot animated:animated withCallback:nil];
}

- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) pivot animated:(BOOL) animated withCallback:(id<RMMapContentsAnimationCallback>)callback
{
	zoomFactor = [self adjustZoomForBoundingMask:zoomFactor];
	
	if (animated)
	{
		float zoomDelta = log2f(zoomFactor);
		float targetZoom = zoomDelta + [self zoom];
		
		// goal is to complete the animation in animTime seconds
		static const float stepTime = 0.03f;
		static const float animTime = 0.1f;
		float nSteps = animTime / stepTime;
		float zoomIncr = zoomDelta / nSteps;
		
		CFDictionaryRef pivotDictionary = CGPointCreateDictionaryRepresentation(pivot);
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithFloat:zoomIncr], @"zoomIncr", 
								  [NSNumber numberWithFloat:targetZoom], @"targetZoom", 
								  pivotDictionary, @"pivot", 
								  callback, @"callback", nil];
		CFRelease(pivotDictionary);
		[NSTimer scheduledTimerWithTimeInterval:stepTime
										 target:self 
									   selector:@selector(animatedZoomStep:) 
									   userInfo:userInfo
										repeats:YES];
	}
	else
	{
		if(([self zoom] >= [self minZoom]) && ([self zoom] <= [self maxZoom]))
		{
			[mercatorToScreenProjection zoomScreenByFactor:zoomFactor near:pivot];
			[imagesOnScreen zoomByFactor:zoomFactor near:pivot];
			[tileLoader zoomByFactor:zoomFactor near:pivot];
			[overlay zoomByFactor:zoomFactor near:pivot];
			[renderer setNeedsDisplay];
		}
		else
		{
			if([self zoom] > [self maxZoom])
				[self setZoom:[self maxZoom]];
			if([self zoom] < [self minZoom])
				[self setZoom:[self minZoom]];
		}
	}
}

- (void)animatedZoomStep:(NSTimer *)timer
{
	float zoomIncr = [[[timer userInfo] objectForKey:@"zoomIncr"] floatValue];
	float targetZoom = [[[timer userInfo] objectForKey:@"targetZoom"] floatValue];

	if ((zoomIncr > 0 && [self zoom] >= targetZoom) || (zoomIncr < 0 && [self zoom] <= targetZoom))
	{
		NSDictionary * userInfo = [[timer userInfo] retain];
		[timer invalidate];	// ASAP
		id<RMMapContentsAnimationCallback> callback = [userInfo objectForKey:@"callback"];
		if (callback && [callback respondsToSelector:@selector(animationFinishedWithZoomFactor:near:)]) {
			CGPoint pivot;
			CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)[userInfo objectForKey:@"pivot"], &pivot);
			[callback animationFinishedWithZoomFactor:targetZoom near:pivot];
		}
		[userInfo release];
	}
	else
	{
		float zoomFactorStep = exp2f(zoomIncr);

		CGPoint pivot;
		CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)[[timer userInfo] objectForKey:@"pivot"], &pivot);
		
		[self zoomByFactor:zoomFactorStep near:pivot animated:NO];
	}
}


- (void)zoomInToNextNativeZoomAt:(CGPoint) pivot
{
	[self zoomInToNextNativeZoomAt:pivot animated:NO];
}

- (float)getNextNativeZoomFactor
{
	float newZoom = roundf([self zoom] + 1);
	return newZoom >= [self maxZoom] ? 0 : exp2f(newZoom - [self zoom]);
}

- (void)zoomInToNextNativeZoomAt:(CGPoint) pivot animated:(BOOL) animated
{
	// Calculate rounded zoom
	float newZoom = roundf([self zoom] + 1);
	
	if (newZoom >= [self maxZoom])
		return;
	else
	{
		float factor = exp2f(newZoom - [self zoom]);
		[self zoomByFactor:factor near:pivot animated:animated];
	}
}

- (void)zoomOutToNextNativeZoomAt:(CGPoint) pivot animated:(BOOL) animated {
       // Calculate rounded zoom
       float newZoom = roundf([self zoom] - 1);
      
       if (newZoom <= [self minZoom])
               return;
       else {
               float factor = exp2f(newZoom - [self zoom]);
               [self zoomByFactor:factor near:pivot animated:animated];
       }
}

- (void)zoomOutToNextNativeZoomAt:(CGPoint) pivot {
       [self zoomOutToNextNativeZoomAt: pivot animated: FALSE];
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

	// TODO: Fix the min / max zoom.
//	[self setMinZoom:[newTileSource minZoom]];
//	[self setMaxZoom:[newTileSource maxZoom]];
	
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
	
	[imagesOnScreen setDelegate:newRenderer];
	
	[[renderer layer] removeFromSuperlayer];
	[renderer release];
	
	renderer = [newRenderer retain];
	
	if (renderer == nil)
		return;
	
	//	CGRect rect = [self screenBounds];
	//	RMLog(@"%f %f %f %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
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
	if (background == aLayer) return;
	
	if (background != nil)
	{
		[background release];
		[background removeFromSuperlayer];		
	}
	
	background = [aLayer retain];
	
	if (background == nil)
		return;
	
	background.frame = [self screenBounds];
	
	if ([renderer layer] != nil)
		[layer insertSublayer:background below:[renderer layer]];
	else if (overlay != nil)
		[layer insertSublayer:background below:overlay];
	else
		[layer insertSublayer:[renderer layer] atIndex: 0];
}

- (RMMapLayer *)background
{
	return [[background retain] autorelease];
}

- (void) setOverlay: (RMLayerSet*) aLayer
{
	if (overlay == aLayer) return;
	
	if (overlay != nil)
	{
		[overlay release];
		[overlay removeFromSuperlayer];		
	}
	
	overlay = [aLayer retain];
	
	if (overlay == nil)
		return;
	
	overlay.frame = [self screenBounds];
	
	if ([renderer layer] != nil)
		[layer insertSublayer:overlay above:[renderer layer]];
	else if (background != nil)
		[layer insertSublayer:overlay above:background];
	else
		[layer insertSublayer:[renderer layer] atIndex: 0];
	
	/* Test to make sure the overlay is working.
	CALayer *testLayer = [[CALayer alloc] init];
	
	[testLayer setFrame:CGRectMake(100, 100, 200, 200)];
	[testLayer setBackgroundColor:[[UIColor brownColor] CGColor]];
	
	RMLog(@"added test layer");
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
	[overlay correctPositionOfAllSublayers];
	[tileLoader updateLoadedImages];
	[renderer setNeedsDisplay];
}

-(float) zoom
{
	return [mercatorToTileProjection calculateZoomFromScale:[mercatorToScreenProjection scale]];
}

/*-(void) setZoom: (float) zoom
{
	//limit the zoom to maxZoom and minZoom as specified by projection - why do we also store maxZoom?
	float normalisedZoom = [mercatorToTileProjection normaliseZoom:zoom];		
	float scale = [mercatorToTileProjection calculateScaleFromZoom:normalisedZoom];
	[self setScale:scale];	
}
*/
-(void) setZoom: (float) zoom
{
	//RMLog(@"set zoom: %f", zoom);
	if (zoom > maxZoom)
        return;
	
	float scale = [mercatorToTileProjection  
				   calculateScaleFromZoom:zoom];
	//RMLog(@"new scale: %f, scale");
	[self setScale:scale];    
	
} 

-(RMTileImageSet*) imagesOnScreen
{
	return [[imagesOnScreen retain] autorelease];
}

-(RMTileLoader*) tileLoader
{
	return [[tileLoader retain] autorelease];
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
		CLLocationCoordinate2D midpoint = {
			.latitude = (ne.latitude + sw.latitude) / 2,
			.longitude = (ne.longitude + sw.longitude) / 2
		};
		RMXYPoint myOrigin = [projection latLongToPoint:midpoint];
		RMXYPoint nePoint = [projection latLongToPoint:ne];
		RMXYPoint swPoint = [projection latLongToPoint:sw];
		RMXYPoint myPoint = {.x = nePoint.x - swPoint.x, .y = nePoint.y - swPoint.y};
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
		RMLog(@"Origin is calculated at: %f, %f", [projection pointToLatLong:myOrigin].latitude, [projection pointToLatLong:myOrigin].longitude);
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

- (RMLatLongBounds) getScreenCoordinateBounds
{
	CGRect rect = [mercatorToScreenProjection screenBounds];
	
	return [self getCoordinateBounds:rect];
}

- (RMLatLongBounds) getCoordinateBounds:(CGRect) rect
{	
	RMLatLongBounds bounds;
	CGPoint northWest = rect.origin;
	
	CGPoint southEast;
	southEast.x = rect.origin.x + rect.size.width;
	southEast.y = rect.origin.y + rect.size.height;
	
//	RMLog(@"NortWest x:%lf y:%lf", northWest.x, northWest.y);
//	RMLog(@"SouthEast x:%lf y:%lf", southEast.x, southEast.y);
	
	bounds.northWest = [self pixelToLatLong:northWest];
	bounds.southEast = [self pixelToLatLong:southEast];
	
//	RMLog(@"NortWest Lat:%lf Lon:%lf", bounds.northWest.latitude, bounds.northWest.longitude);
//	RMLog(@"SouthEast Lat:%lf Lon:%lf", bounds.southEast.latitude, bounds.southEast.longitude);
	
	return bounds;
}

- (void) tilesUpdatedRegion:(CGRect)region
{
	if(delegateHasRegionUpdate)
	{
		RMLatLongBounds locationBounds  = [self getCoordinateBounds:region];
		[tilesUpdateDelegate regionUpdate:locationBounds];
	}
}
- (void) printDebuggingInformation
{
	[imagesOnScreen printDebuggingInformation];
}

@dynamic tilesUpdateDelegate;

- (void) setTilesUpdateDelegate: (id<RMTilesUpdateDelegate>) _tilesUpdateDelegate
{
	if (tilesUpdateDelegate == _tilesUpdateDelegate) return;
	tilesUpdateDelegate= _tilesUpdateDelegate;
	//RMLog(@"Delegate type:%@",[(NSObject *) tilesUpdateDelegate description]);
	delegateHasRegionUpdate  = [(NSObject*) tilesUpdateDelegate respondsToSelector: @selector(regionUpdate:)];
}

- (id<RMTilesUpdateDelegate>) tilesUpdateDelegate
{
	return tilesUpdateDelegate;
}

@end
