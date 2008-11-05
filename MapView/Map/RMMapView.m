//
//  RMMapView.m
//  MapView
//
//  Created by Joseph Gentle on 24/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMMapView.h"
#import "RMMapContents.h"
#import "RMMapViewDelegate.h"

#import "RMTileLoader.h"

#import "RMMercatorToScreenProjection.h"
#import "RMMarker.h"

@implementation RMMapView (Internal)
	BOOL delegateHasBeforeMapMove;
	BOOL delegateHasAfterMapMove;
	BOOL delegateHasBeforeMapZoomByFactor;
	BOOL delegateHasAfterMapZoomByFactor;
	BOOL delegateHasDoubleTapOnMap;
	BOOL delegateHasTapOnMarker;
@end

@implementation RMMapView

-(void) initValues
{
	contents = [[RMMapContents alloc] initForView:self];
	
	enableDragging = YES;
	enableZoom = YES;
	
	//	[self recalculateImageSet];
	
	if (enableZoom)
		[self setMultipleTouchEnabled:TRUE];
	
	self.backgroundColor = [UIColor grayColor];
	
//	[[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		[self initValues];
	}
	return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self initValues];
}

-(void) dealloc
{
	[contents release];
	[super dealloc];
}

-(void) drawRect: (CGRect) rect
{
	[contents drawRect:rect];
}

-(NSString*) description
{
	CGRect bounds = [self bounds];
	return [NSString stringWithFormat:@"iPhone MapView at %.0f,%.0f-%.0f,%.0f", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height];
}

-(RMMapContents*) contents
{
	return [[contents retain] autorelease];
}

#pragma mark Delegate 

@dynamic delegate;

- (void) setDelegate: (id<RMMapViewDelegate>) _delegate
{
	if (delegate == _delegate) return;
	delegate = _delegate;
	
	delegateHasBeforeMapMove = [(NSObject*) delegate respondsToSelector: @selector(beforeMapMove:)];
	delegateHasAfterMapMove  = [(NSObject*) delegate respondsToSelector: @selector(afterMapMove:)];
	
	delegateHasBeforeMapZoomByFactor = [(NSObject*) delegate respondsToSelector: @selector(beforeMapZoom: byFactor: near:)];
	delegateHasAfterMapZoomByFactor  = [(NSObject*) delegate respondsToSelector: @selector(afterMapZoom: byFactor: near:)];

	delegateHasDoubleTapOnMap = [(NSObject*) delegate respondsToSelector: @selector(doubleTapOnMap:)];	
	delegateHasTapOnMarker = [(NSObject*) delegate respondsToSelector:@selector(tapOnMarker:onMap:)];
}

- (id<RMMapViewDelegate>) delegate
{
	return delegate;
}

#pragma mark Movement

-(void) moveToXYPoint: (RMXYPoint) aPoint
{
	if (delegateHasBeforeMapMove) [delegate beforeMapMove: self];
	[contents moveToXYPoint:aPoint];
	if (delegateHasAfterMapMove) [delegate afterMapMove: self];
}
-(void) moveToLatLong: (CLLocationCoordinate2D) point
{
	if (delegateHasBeforeMapMove) [delegate beforeMapMove: self];
	[contents moveToLatLong:point];
	if (delegateHasAfterMapMove) [delegate afterMapMove: self];
}

- (void)moveBy: (CGSize) delta
{
	if (delegateHasBeforeMapMove) [delegate beforeMapMove: self];
	[contents moveBy:delta];
	if (delegateHasAfterMapMove) [delegate afterMapMove: self];
}
- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center
{
	if (delegateHasBeforeMapZoomByFactor) [delegate beforeMapZoom: self byFactor: zoomFactor near: center];
	[contents zoomByFactor:zoomFactor near:center];
	if (delegateHasAfterMapZoomByFactor) [delegate afterMapZoom: self byFactor: zoomFactor near: center];
}

#pragma mark Event handling

- (RMGestureDetails) getGestureDetails: (NSSet*) touches
{
	RMGestureDetails gesture;
	gesture.center.x = gesture.center.y = 0;
	gesture.averageDistanceFromCenter = 0;
	
	int interestingTouches = 0;
	
	for (UITouch *touch in touches)
	{
		if ([touch phase] != UITouchPhaseBegan
			&& [touch phase] != UITouchPhaseMoved
			&& [touch phase] != UITouchPhaseStationary)
			continue;
		//		NSLog(@"phase = %d", [touch phase]);
		
		interestingTouches++;
		
		CGPoint location = [touch locationInView: self];
		
		gesture.center.x += location.x;
		gesture.center.y += location.y;
	}
	
	if (interestingTouches == 0)
	{
		gesture.center = lastGesture.center;
		gesture.numTouches = 0;
		gesture.averageDistanceFromCenter = 0.0f;
		return gesture;
	}
	
	//	NSLog(@"interestingTouches = %d", interestingTouches);
	
	gesture.center.x /= interestingTouches;
	gesture.center.y /= interestingTouches;
	
	for (UITouch *touch in touches)
	{
		if ([touch phase] != UITouchPhaseBegan
			&& [touch phase] != UITouchPhaseMoved
			&& [touch phase] != UITouchPhaseStationary)
			continue;
		
		CGPoint location = [touch locationInView: self];
		
		//		NSLog(@"For touch at %.0f, %.0f:", location.x, location.y);
		float dx = location.x - gesture.center.x;
		float dy = location.y - gesture.center.y;
		//		NSLog(@"delta = %.0f, %.0f  distance = %f", dx, dy, sqrtf((dx*dx) + (dy*dy)));
		gesture.averageDistanceFromCenter += sqrtf((dx*dx) + (dy*dy));
	}
	
	gesture.averageDistanceFromCenter /= interestingTouches;
	
	gesture.numTouches = interestingTouches;
	
	//	NSLog(@"center = %.0f,%.0f dist = %f", gesture.center.x, gesture.center.y, gesture.averageDistanceFromCenter);
	
	return gesture;
}

- (void)userPausedDragging
{
	[RMMapContents setPerformExpensiveOperations:YES];
//	NSLog(@"expensive.");
}

- (void)unRegisterPausedDraggingDispatcher
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(userPausedDragging) object:nil];
}

- (void)registerPausedDraggingDispatcher
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(userPausedDragging) object:nil];
	[self performSelector:@selector(userPausedDragging) withObject:nil afterDelay:0.3];	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (lastGesture.numTouches == 0)
	{
		[RMMapContents setPerformExpensiveOperations:NO];
	}
	
	//	NSLog(@"touchesBegan %d", [[event allTouches] count]);
	lastGesture = [self getGestureDetails:[event allTouches]];
	
	[self registerPausedDraggingDispatcher];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	// I don't understand what the difference between this and touchesEnded is.
	[self touchesEnded:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [[touches allObjects] objectAtIndex:0];
	lastGesture = [self getGestureDetails:[event allTouches]];
	
	//	NSLog(@"touchesEnded %d  ... lastgesture at %f, %f", [[event allTouches] count], lastGesture.center.x, lastGesture.center.y);
	
	//	NSLog(@"Assemble.");

	if (lastGesture.numTouches == 0)
	{
		[self unRegisterPausedDraggingDispatcher];
		// When factoring, beware these two instructions need to happen in this order.
		[RMMapContents setPerformExpensiveOperations:YES];
	}

	if (touch.tapCount == 2)
	{
		if (delegateHasDoubleTapOnMap) {
			[delegate doubleTapOnMap: self];
		} else {
			// TODO: default behaviour
			// [contents zoomInToNextNativeZoom];
		}
	}
	
	if (touch.tapCount == 1) 
	{
		CALayer* hit = [contents.overlay hitTest:[touch locationInView:self]];
		if (hit != nil && [hit isMemberOfClass: [RMMarker class]]) {
			if (delegateHasTapOnMarker) [delegate tapOnMarker: (RMMarker*) hit onMap: self];
		}
	}
	
//		[contents recalculateImageSet];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	RMGestureDetails newGesture = [self getGestureDetails:[event allTouches]];
	
	if (enableDragging && newGesture.numTouches == lastGesture.numTouches)
	{
		CGSize delta;
		delta.width = newGesture.center.x - lastGesture.center.x;
		delta.height = newGesture.center.y - lastGesture.center.y;
		
		if (enableZoom && newGesture.numTouches > 1)
		{
			NSAssert (lastGesture.averageDistanceFromCenter > 0.0f && newGesture.averageDistanceFromCenter > 0.0f,
					  @"Distance from center is zero despite >1 touches on the screen");
			
			double zoomFactor = newGesture.averageDistanceFromCenter / lastGesture.averageDistanceFromCenter;
			
			[self moveBy:delta];
			[self zoomByFactor: zoomFactor near: newGesture.center];
		}
		else
		{
			[self moveBy:delta];
		}
		
	}
	
	lastGesture = newGesture;
	
	[self registerPausedDraggingDispatcher];
}

#pragma mark LatLng/Pixel translation functions

- (CGPoint)latLongToPixel:(CLLocationCoordinate2D)latlong
{
	return [contents latLongToPixel:latlong];
}
- (CLLocationCoordinate2D)pixelToLatLong:(CGPoint)pixel
{
	return [contents pixelToLatLong:pixel];
}

#pragma mark Manual Zoom
- (void)setZoom:(int)zoomInt
{
	[contents setZoom:zoomInt];
}

#pragma mark Zoom With Bounds
- (void)zoomWithLatLngBoundsNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)se
{
	[contents zoomWithLatLngBoundsNorthEast:ne SouthWest:se];
}


#pragma mark Markers

- (void) addMarker: (RMMarker*)marker
{
	[contents addMarker:marker];
}
- (void) addMarker: (RMMarker*)marker AtLatLong:(CLLocationCoordinate2D)point
{
	[contents addMarker:marker AtLatLong:point];
}
- (void) addDefaultMarkerAt: (CLLocationCoordinate2D)point
{
	[contents addDefaultMarkerAt:point];
}

- (void) removeMarkers
{
	[contents removeMarkers];
}

- (NSArray *) getMarkers
{
	return [contents getMarkers];
}

- (void) removeMarker: (RMMarker *)marker
{
	[contents removeMarker:marker];
}

- (CGPoint) getMarkerScreenCoordinate: (RMMarker *)marker
{
	return [contents getMarkerScreenCoordinate:marker];
}

@end
