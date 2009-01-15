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

#import "RMMarkerManager.h"

@interface RMMapView (PrivateMethods)
// methods for post-touch deceleration, ala UIScrollView
- (void)startDecelerationWithDelta:(CGSize)delta;
- (void)incrementDeceleration:(NSTimer *)timer;
- (void)stopDeceleration;
@end

@implementation RMMapView (Internal)
	BOOL delegateHasBeforeMapMove;
	BOOL delegateHasAfterMapMove;
	BOOL delegateHasBeforeMapZoomByFactor;
	BOOL delegateHasAfterMapZoomByFactor;
	BOOL delegateHasDoubleTapOnMap;
	BOOL delegateHasSingleTapOnMap;
	BOOL delegateHasTapOnMarker;
	BOOL delegateHasTapOnLabelForMarker;
	BOOL delegateHasAfterMapTouch;
	BOOL delegateHasDragMarkerPosition;
	NSTimer *decelerationTimer;
	CGSize decelerationDelta;
@end

@implementation RMMapView
@synthesize decelerationFactor;

- (RMMarkerManager*)markerManager
{
  return contents.markerManager;
}

-(void) initValues:(CLLocationCoordinate2D)latlong
{
	if(round(latlong.latitude) != 0 && round(latlong.longitude) != 0)
	{
		contents = [[RMMapContents alloc] initForView:self WithLocation:latlong];
	}else
	{
		contents = [[RMMapContents alloc] initForView:self];
	}
	
	enableDragging = YES;
	enableZoom = YES;
	decelerationFactor = 0.88f;
	
	//	[self recalculateImageSet];
	
	if (enableZoom)
		[self setMultipleTouchEnabled:TRUE];
	
	self.backgroundColor = [UIColor grayColor];
	
//	[[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (id)initWithFrame:(CGRect)frame
{
	CLLocationCoordinate2D latlong;
	
	if (self = [super initWithFrame:frame]) {
		[self initValues:latlong];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame WithLocation:(CLLocationCoordinate2D)latlong
{
	if (self = [super initWithFrame:frame]) {
		[self initValues:latlong];
	}
	return self;
}

- (void)awakeFromNib
{
	CLLocationCoordinate2D latlong = {0, 0};
	[super awakeFromNib];
	[self initValues:latlong];
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
	return [NSString stringWithFormat:@"MapView at %.0f,%.0f-%.0f,%.0f", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height];
}

-(RMMapContents*) contents
{
	return [[contents retain] autorelease];
}

// Forward invocations to RMMapContents
- (void)forwardInvocation:(NSInvocation *)invocation
{
    SEL aSelector = [invocation selector];
	
    if ([contents respondsToSelector:aSelector])
        [invocation invokeWithTarget:contents];
    else
        [self doesNotRecognizeSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	if ([super respondsToSelector:aSelector])
		return [super methodSignatureForSelector:aSelector];
	else
		return [contents methodSignatureForSelector:aSelector];
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

	delegateHasDoubleTapOnMap = [(NSObject*) delegate respondsToSelector: @selector(doubleTapOnMap:At:)];
	delegateHasSingleTapOnMap = [(NSObject*) delegate respondsToSelector: @selector(singleTapOnMap:At:)];
	
	delegateHasTapOnMarker = [(NSObject*) delegate respondsToSelector:@selector(tapOnMarker:onMap:)];
	delegateHasTapOnLabelForMarker = [(NSObject*) delegate respondsToSelector:@selector(tapOnLabelForMarker:onMap:)];
	
	delegateHasAfterMapTouch  = [(NSObject*) delegate respondsToSelector: @selector(afterMapTouch:)];
	
	delegateHasDragMarkerPosition = [(NSObject*) delegate respondsToSelector: @selector(dragMarkerPosition: onMap: position:)];
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
	UITouch *touch = [[touches allObjects] objectAtIndex:0];
	//Check if the touch hit a RMMarker subclass and if so, forward the touch event on
	//so it can be handled there
	id furthestLayerDown = [[[self contents] overlay] hitTest:[touch locationInView:self]];
	if ([[furthestLayerDown class]isSubclassOfClass: [RMMarker class]]) {
		if ([furthestLayerDown respondsToSelector:@selector(touchesBegan:withEvent:)]) {
			[furthestLayerDown performSelector:@selector(touchesBegan:withEvent:) withObject:touches withObject:event];
			return;
		}
	}
		
	if (lastGesture.numTouches == 0)
	{
		[RMMapContents setPerformExpensiveOperations:NO];
	}
	
	//	NSLog(@"touchesBegan %d", [[event allTouches] count]);
	lastGesture = [self getGestureDetails:[event allTouches]];

	if (decelerationTimer != nil) {
		[self stopDeceleration];
	}

	[self registerPausedDraggingDispatcher];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [[touches allObjects] objectAtIndex:0];
	
	//Check if the touch hit a RMMarker subclass and if so, forward the touch event on
	//so it can be handled there
	id furthestLayerDown = [[[self contents] overlay] hitTest:[touch locationInView:self]];
	if ([[furthestLayerDown class]isSubclassOfClass: [RMMarker class]]) {
		if ([furthestLayerDown respondsToSelector:@selector(touchesCancelled:withEvent:)]) {
			[furthestLayerDown performSelector:@selector(touchesCancelled:withEvent:) withObject:touches withObject:event];
			return;
		}
	}

	// I don't understand what the difference between this and touchesEnded is.
	[self touchesEnded:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [[touches allObjects] objectAtIndex:0];
	
	//Check if the touch hit a RMMarker subclass and if so, forward the touch event on
	//so it can be handled there
	id furthestLayerDown = [[[self contents] overlay] hitTest:[touch locationInView:self]];
	if ([[furthestLayerDown class]isSubclassOfClass: [RMMarker class]]) {
		if ([furthestLayerDown respondsToSelector:@selector(touchesEnded:withEvent:)]) {
			[furthestLayerDown performSelector:@selector(touchesEnded:withEvent:) withObject:touches withObject:event];
			return;
		}
	}
	NSInteger lastTouches = lastGesture.numTouches;
	
	// Calculate the gesture.
	lastGesture = [self getGestureDetails:[event allTouches]];

	// If there are no more fingers on the screen, resume any slow operations.
	if (lastGesture.numTouches == 0)
	{
		[self unRegisterPausedDraggingDispatcher];
		// When factoring, beware these two instructions need to happen in this order.
		[RMMapContents setPerformExpensiveOperations:YES];
	}

	if (touch.tapCount >= 2)
	{
		if (delegateHasDoubleTapOnMap) {
			[delegate doubleTapOnMap: self At: lastGesture.center];
		} else {
			// Default behaviour matches built in maps.app
			[self zoomInToNextNativeZoomAt: [touch locationInView:self]];
		}
	} else if (lastTouches == 1 && touch.tapCount != 1) {
		// deceleration
		CGPoint prevLocation = [touch previousLocationInView:self];
		CGPoint currLocation = [touch locationInView:self];
		CGSize touchDelta = CGSizeMake(currLocation.x - prevLocation.x, currLocation.y - prevLocation.y);
		[self startDecelerationWithDelta:touchDelta];
	}
	
		
	if (touch.tapCount == 1) 
	{
		CALayer* hit = [contents.overlay hitTest:[touch locationInView:self]];
//		NSLog(@"LAYER of type %@",[hit description]);
		
		if (hit != nil) {
			CALayer *superlayer = [hit superlayer];
			
			// See if tap was on a marker or marker label and send delegate protocol method
			if ([hit isMemberOfClass: [RMMarker class]]) {
				if (delegateHasTapOnMarker) {
					[delegate tapOnMarker:(RMMarker*)hit onMap:self];
				}
			} else if (superlayer != nil && [superlayer isMemberOfClass: [RMMarker class]]) {
				if (delegateHasTapOnLabelForMarker) {
					[delegate tapOnLabelForMarker:(RMMarker*)superlayer onMap:self];
				}
			}
			else if (delegateHasSingleTapOnMap) {
				[delegate singleTapOnMap: self At: [touch locationInView:self]];
			}
		}
		
	}

	if (delegateHasAfterMapTouch) [delegate afterMapTouch: self];

//		[contents recalculateImageSet];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [[touches allObjects] objectAtIndex:0];
	
	//Check if the touch hit a RMMarker subclass and if so, forward the touch event on
	//so it can be handled there
	id furthestLayerDown = [[[self contents] overlay] hitTest:[touch locationInView:self]];
	if ([[furthestLayerDown class]isSubclassOfClass: [RMMarker class]]) {
		if ([furthestLayerDown respondsToSelector:@selector(touchesMoved:withEvent:)]) {
			[furthestLayerDown performSelector:@selector(touchesMoved:withEvent:) withObject:touches withObject:event];
			return;
		}
	}
	
	CALayer* hit = [contents.overlay hitTest:[touch locationInView:self]];
//	NSLog(@"LAYER of type %@",[hit description]);
	
	if (hit != nil) {
		
		if ([hit isMemberOfClass: [RMMarker class]]) {
			if (delegateHasDragMarkerPosition) {
				[delegate dragMarkerPosition:(RMMarker*)hit onMap:self position:[[[event allTouches] anyObject]locationInView:self]];
				return;
			}
		}
	}
	
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

#pragma mark Deceleration

- (void)startDecelerationWithDelta:(CGSize)delta {
	if (ABS(delta.width) >= 1.0f && ABS(delta.height) >= 1.0f) {
		decelerationDelta = delta;
		decelerationTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f 
															 target:self
														   selector:@selector(incrementDeceleration:) 
														   userInfo:nil 
															repeats:YES];
	}
}

- (void)incrementDeceleration:(NSTimer *)timer {
	if (ABS(decelerationDelta.width) < 0.01f && ABS(decelerationDelta.height) < 0.01f) {
		[self stopDeceleration];
		return;
	}

	// avoid calling delegate methods? design call here
	[contents moveBy:decelerationDelta];

	decelerationDelta.width *= [self decelerationFactor];
	decelerationDelta.height *= [self decelerationFactor];
}

- (void)stopDeceleration {
	if (decelerationTimer != nil) {
		[decelerationTimer invalidate];
		decelerationTimer = nil;
		decelerationDelta = CGSizeZero;

		// call delegate methods; design call (see above)
		[self moveBy:CGSizeZero];
	}
}

- (void)didReceiveMemoryWarning
{
  CLLocationCoordinate2D coord = contents.mapCenter;
  [contents release];
  [self initValues:coord];
}

- (void)setFrame:(CGRect)frame
{
  CGRect r = self.frame;
  [super setFrame:frame];
  // only change if the frame changes AND there is contents
  if (!CGRectEqualToRect(r, frame) && contents) {
    CLLocationCoordinate2D coord = contents.mapCenter;
    float zoom = contents.zoom;
    [contents release];
    [self initValues:coord];
    contents.zoom = zoom;
  }
}

@end
