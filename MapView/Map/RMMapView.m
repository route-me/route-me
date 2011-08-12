//
//  RMMapView.m
//
// Copyright (c) 2008-2009, Route-Me Contributors
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

#import "RMMapView.h"
#import "RMMapContents.h"
#import "RMMapViewDelegate.h"

#import "RMTileLoader.h"

#import "RMMercatorToScreenProjection.h"
#import "RMMarker.h"
#import "RMProjection.h"
#import "RMMarkerManager.h"

@interface RMMapView (PrivateMethods)
// methods for post-touch deceleration, ala UIScrollView
- (void)startDecelerationWithDelta:(CGSize)delta;
- (void)incrementDeceleration:(NSTimer *)timer;
- (void)stopDeceleration;
@end

@implementation RMMapView
@synthesize contents;

@synthesize decelerationFactor;
@synthesize deceleration;

@synthesize rotation;

@synthesize enableDragging;
@synthesize enableZoom;
@synthesize enableRotate;

#pragma mark --- begin constants ----
#define kDefaultDecelerationFactor .88f
#define kMinDecelerationDelta 0.01f
#pragma mark --- end constants ----

- (RMMarkerManager*)markerManager
{
  return self.contents.markerManager;
}

-(void) performInitialSetup
{
	LogMethod();

	enableDragging = YES;
	enableZoom = YES;
	enableRotate = NO;
	decelerationFactor = kDefaultDecelerationFactor;
	deceleration = NO;
	
	//	[self recalculateImageSet];
	
	if (enableZoom || enableRotate)
		[self setMultipleTouchEnabled:TRUE];
	
	self.backgroundColor = [UIColor grayColor];
	
	_constrainMovement=NO;
	
//	[[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (id)initWithFrame:(CGRect)frame
{
	LogMethod();
	if (self = [super initWithFrame:frame]) {
		[self performInitialSetup];
	}
	return self;
}

/// \deprecated Deprecated any time after 0.5.
- (id)initWithFrame:(CGRect)frame WithLocation:(CLLocationCoordinate2D)latlon
{
	WarnDeprecated();
	LogMethod();
	if (self = [super initWithFrame:frame]) {
		[self performInitialSetup];
	}
	[self moveToLatLong:latlon];
	return self;
}

//=========================================================== 
//  contents 
//=========================================================== 
- (RMMapContents *)contents
{
    if (!_contentsIsSet) {
		RMMapContents *newContents = [[RMMapContents alloc] initWithView:self];
		self.contents = newContents;
		[newContents release];
		_contentsIsSet = YES;
	}
	return contents; 
}
- (void)setContents:(RMMapContents *)theContents
{
    if (contents != theContents) {
        [contents release];
        contents = [theContents retain];
		_contentsIsSet = YES;
		[self performInitialSetup];
    }
}

-(void) dealloc
{
	LogMethod();
	self.contents = nil;
	[super dealloc];
}

-(void) drawRect: (CGRect) rect
{
	[self.contents drawRect:rect];
}

-(NSString*) description
{
	CGRect bounds = [self bounds];
	return [NSString stringWithFormat:@"MapView at %.0f,%.0f-%.0f,%.0f", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height];
}

/// Forward invocations to RMMapContents
- (void)forwardInvocation:(NSInvocation *)invocation
{
    SEL aSelector = [invocation selector];
	
    if ([self.contents respondsToSelector:aSelector])
        [invocation invokeWithTarget:self.contents];
    else
        [self doesNotRecognizeSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	if ([super respondsToSelector:aSelector])
		return [super methodSignatureForSelector:aSelector];
	else
		return [self.contents methodSignatureForSelector:aSelector];
}

#pragma mark Delegate 

@dynamic delegate;

- (void) setDelegate: (id<RMMapViewDelegate>) _delegate
{
	if (delegate == _delegate) return;
	delegate = _delegate;
	
	_delegateHasBeforeMapMove = [(NSObject*) delegate respondsToSelector: @selector(beforeMapMove:)];
	_delegateHasAfterMapMove  = [(NSObject*) delegate respondsToSelector: @selector(afterMapMove:)];
	
	_delegateHasBeforeMapZoomByFactor = [(NSObject*) delegate respondsToSelector: @selector(beforeMapZoom: byFactor: near:)];
	_delegateHasAfterMapZoomByFactor  = [(NSObject*) delegate respondsToSelector: @selector(afterMapZoom: byFactor: near:)];
	
	_delegateHasMapViewRegionDidChange = [delegate respondsToSelector:@selector(mapViewRegionDidChange:)];

	_delegateHasBeforeMapRotate  = [(NSObject*) delegate respondsToSelector: @selector(beforeMapRotate: fromAngle:)];
	_delegateHasAfterMapRotate  = [(NSObject*) delegate respondsToSelector: @selector(afterMapRotate: toAngle:)];

	_delegateHasDoubleTapOnMap = [(NSObject*) delegate respondsToSelector: @selector(doubleTapOnMap:At:)];
	_delegateHasSingleTapOnMap = [(NSObject*) delegate respondsToSelector: @selector(singleTapOnMap:At:)];
	
	_delegateHasTapOnMarker = [(NSObject*) delegate respondsToSelector:@selector(tapOnMarker:onMap:)];
	_delegateHasTapOnLabelForMarker = [(NSObject*) delegate respondsToSelector:@selector(tapOnLabelForMarker:onMap:)];
	
	_delegateHasAfterMapTouch  = [(NSObject*) delegate respondsToSelector: @selector(afterMapTouch:)];
   
   	_delegateHasShouldDragMarker = [(NSObject*) delegate respondsToSelector: @selector(mapView: shouldDragMarker: withEvent:)];
   	_delegateHasDidDragMarker = [(NSObject*) delegate respondsToSelector: @selector(mapView: didDragMarker: withEvent:)];
	
	_delegateHasDragMarkerPosition = [(NSObject*) delegate respondsToSelector: @selector(dragMarkerPosition: onMap: position:)];
}

- (id<RMMapViewDelegate>) delegate
{
	return delegate;
}

#pragma mark Movement

-(void) moveToProjectedPoint: (RMProjectedPoint) aPoint
{
	if (_delegateHasBeforeMapMove) [delegate beforeMapMove: self];
	[self.contents moveToProjectedPoint:aPoint];
	if (_delegateHasAfterMapMove) [delegate afterMapMove: self];
	if (_delegateHasMapViewRegionDidChange) [delegate mapViewRegionDidChange:self];
}
-(void) moveToLatLong: (CLLocationCoordinate2D) point
{
	if (_delegateHasBeforeMapMove) [delegate beforeMapMove: self];
	[self.contents moveToLatLong:point];
	if (_delegateHasAfterMapMove) [delegate afterMapMove: self];
	if (_delegateHasMapViewRegionDidChange) [delegate mapViewRegionDidChange:self];
}

-(void)setConstraintsSW:(CLLocationCoordinate2D)sw NE:(CLLocationCoordinate2D)ne
{
	//store projections
	RMProjection *proj=self.contents.projection;
	
	RMProjectedPoint projectedNE = [proj latLongToPoint:ne];
	RMProjectedPoint projectedSW = [proj latLongToPoint:sw];
	
	[self setProjectedContraintsSW:projectedSW NE:projectedNE];
}

- (void)setProjectedContraintsSW:(RMProjectedPoint)sw NE:(RMProjectedPoint)ne {
	SWconstraint = sw;
	NEconstraint = ne;
	
	_constrainMovement=YES;
}

-(void)moveBy:(CGSize)delta 
{

	if ( _constrainMovement ) 
	{
		//bounds are
		RMMercatorToScreenProjection *mtsp=self.contents.mercatorToScreenProjection;
		
		//calculate new bounds after move
		RMProjectedRect pBounds=[mtsp projectedBounds];
		RMProjectedSize XYDelta = [mtsp projectScreenSizeToXY:delta];
        CGSize sizeRatio = CGSizeMake(((delta.width == 0) ? 0 : XYDelta.width / delta.width),
									  ((delta.height == 0) ? 0 : XYDelta.height / delta.height));
		RMProjectedRect newBounds=pBounds;
        
		//move the rect by delta
		newBounds.origin.northing -= XYDelta.height;
		newBounds.origin.easting -= XYDelta.width; 
		
		// see if new bounds are within constrained bounds, and constrain if necessary
        BOOL constrained = NO;
		if ( newBounds.origin.northing < SWconstraint.northing ) { newBounds.origin.northing = SWconstraint.northing; constrained = YES; }
        if ( newBounds.origin.northing+newBounds.size.height > NEconstraint.northing ) { newBounds.origin.northing = NEconstraint.northing - newBounds.size.height; constrained = YES; }
        if ( newBounds.origin.easting < SWconstraint.easting ) { newBounds.origin.easting = SWconstraint.easting; constrained = YES; }
        if ( newBounds.origin.easting+newBounds.size.width > NEconstraint.easting ) { newBounds.origin.easting = NEconstraint.easting - newBounds.size.width; constrained = YES; }
        if ( constrained ) 
        {
            // Adjust delta to match constraint
            XYDelta.height = pBounds.origin.northing - newBounds.origin.northing;
            XYDelta.width = pBounds.origin.easting - newBounds.origin.easting;
            delta = CGSizeMake(((sizeRatio.width == 0) ? 0 : XYDelta.width / sizeRatio.width), 
                               ((sizeRatio.height == 0) ? 0 : XYDelta.height / sizeRatio.height));
        }
	}

	if (_delegateHasBeforeMapMove) [delegate beforeMapMove: self];
	[self.contents moveBy:delta];
	if (_delegateHasAfterMapMove) [delegate afterMapMove: self];
	if (_delegateHasMapViewRegionDidChange) [delegate mapViewRegionDidChange:self];
}
 
- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center
{
	[self zoomByFactor:zoomFactor near:center animated:NO];
}
- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center animated:(BOOL)animated
{
	if ( _constrainMovement ) 
	{
		//check that bounds after zoom don't exceed map constraints
		//the logic is copued from the method zoomByFactor,
		float _zoomFactor = [self.contents adjustZoomForBoundingMask:zoomFactor];
		float zoomDelta = log2f(_zoomFactor);
		float targetZoom = zoomDelta + [self.contents zoom];
		BOOL canZoom=NO;
		if (targetZoom == [self.contents zoom]){
			//OK... . I could even do a return here.. but it will hamper with future logic..
			canZoom=YES;
		}
		// clamp zoom to remain below or equal to maxZoom after zoomAfter will be applied
		if(targetZoom > [self.contents maxZoom]){
			zoomFactor = exp2f([self.contents maxZoom] - [self.contents zoom]);
		}
		
		// clamp zoom to remain above or equal to minZoom after zoomAfter will be applied
		if(targetZoom < [self.contents minZoom]){
			zoomFactor = 1/exp2f([self.contents zoom] - [self.contents minZoom]);
		}
		
		//bools for syntactical sugar to understand the logic in the if statement below
		BOOL zoomAtMax = ([self.contents  zoom] == [self.contents  maxZoom]);
		BOOL zoomAtMin = ([self.contents  zoom] == [self.contents  minZoom]);
		BOOL zoomGreaterMin = ([self.contents  zoom] > [self.contents  minZoom]);
		BOOL zoomLessMax = ([self.contents  zoom] < [ self.contents maxZoom]);
		
		//zooming in zoomFactor > 1
		//zooming out zoomFactor < 1
		
		if ((zoomGreaterMin && zoomLessMax) || (zoomAtMax && zoomFactor<1) || (zoomAtMin && zoomFactor>1))
		{
			//if I'm here it means I could zoom, now we have to see what will happen after zoom
			RMMercatorToScreenProjection *mtsp= self.contents.mercatorToScreenProjection ;
			
			//get copies of mercatorRoScreenProjection's data
			RMProjectedPoint origin=[mtsp origin];
			float metersPerPixel=mtsp.metersPerPixel;
			CGRect screenBounds=[mtsp screenBounds];
			
			//tjis is copied from [RMMercatorToScreenBounds zoomScreenByFactor]
			// First we move the origin to the pivot...
			origin.easting += center.x * metersPerPixel;
			origin.northing += (screenBounds.size.height - center.y) * metersPerPixel;
			// Then scale by 1/factor
			metersPerPixel /= _zoomFactor;
			// Then translate back
			origin.easting -= center.x * metersPerPixel;
			origin.northing -= (screenBounds.size.height - center.y) * metersPerPixel;
			
			origin = [mtsp.projection wrapPointHorizontally:origin];
			
			//calculate new bounds
			RMProjectedRect zRect;
			zRect.origin = origin;
			zRect.size.width = screenBounds.size.width * metersPerPixel;
			zRect.size.height = screenBounds.size.height * metersPerPixel;
			 
			//can zoom only if within bounds
			canZoom= !(zRect.origin.northing < SWconstraint.northing || zRect.origin.northing+zRect.size.height> NEconstraint.northing ||
			  zRect.origin.easting < SWconstraint.easting || zRect.origin.easting+zRect.size.width > NEconstraint.easting);
				
		}
		
		if(!canZoom){
			RMLog(@"Zooming will move map out of bounds: no zoom");
			return;
		}
	
	}
	
	if (_delegateHasBeforeMapZoomByFactor) [delegate beforeMapZoom: self byFactor: zoomFactor near: center];
	[self.contents zoomByFactor:zoomFactor near:center animated:animated withCallback:(animated && (_delegateHasAfterMapZoomByFactor || _delegateHasMapViewRegionDidChange))?self:nil];
	if (!animated)
	{
		if (_delegateHasAfterMapZoomByFactor) [delegate afterMapZoom: self byFactor: zoomFactor near: center];
		if (_delegateHasMapViewRegionDidChange) [delegate mapViewRegionDidChange:self];
	}
}


#pragma mark RMMapContentsAnimationCallback methods

- (void)animationFinishedWithZoomFactor:(float)zoomFactor near:(CGPoint)p
{
	if (_delegateHasAfterMapZoomByFactor)
		[delegate afterMapZoom: self byFactor: zoomFactor near: p];
}

- (void)animationStepped {
	if (_delegateHasMapViewRegionDidChange) [delegate mapViewRegionDidChange:self];
}

#pragma mark Event handling

- (RMGestureDetails) gestureDetails: (NSSet*) touches
{
	RMGestureDetails gesture;
	gesture.center.x = gesture.center.y = 0;
	gesture.averageDistanceFromCenter = 0;
	gesture.angle = 0.0;
	
	int interestingTouches = 0;
	
	for (UITouch *touch in touches)
	{
		if ([touch phase] != UITouchPhaseBegan
			&& [touch phase] != UITouchPhaseMoved
			&& [touch phase] != UITouchPhaseStationary)
			continue;
		//		RMLog(@"phase = %d", [touch phase]);
		
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
	
	//	RMLog(@"interestingTouches = %d", interestingTouches);
	
	gesture.center.x /= interestingTouches;
	gesture.center.y /= interestingTouches;
	
	for (UITouch *touch in touches)
	{
		if ([touch phase] != UITouchPhaseBegan
			&& [touch phase] != UITouchPhaseMoved
			&& [touch phase] != UITouchPhaseStationary)
			continue;
		
		CGPoint location = [touch locationInView: self];
		
		//		RMLog(@"For touch at %.0f, %.0f:", location.x, location.y);
		float dx = location.x - gesture.center.x;
		float dy = location.y - gesture.center.y;
		//		RMLog(@"delta = %.0f, %.0f  distance = %f", dx, dy, sqrtf((dx*dx) + (dy*dy)));
		gesture.averageDistanceFromCenter += sqrtf((dx*dx) + (dy*dy));
	}

	gesture.averageDistanceFromCenter /= interestingTouches;
	
	gesture.numTouches = interestingTouches;

	if ([touches count] == 2)  
	{
		CGPoint first = [[[touches allObjects] objectAtIndex:0] locationInView:[self superview]];
		CGPoint second = [[[touches allObjects] objectAtIndex:1] locationInView:[self superview]];
		CGFloat height = second.y - first.y;
        CGFloat width = first.x - second.x;
        gesture.angle = atan2(height,width);
	}
	
	//RMLog(@"center = %.0f,%.0f dist = %f, angle = %f", gesture.center.x, gesture.center.y, gesture.averageDistanceFromCenter, gesture.angle);
	
	return gesture;
}

- (void)resumeExpensiveOperations
{
	[RMMapContents setPerformExpensiveOperations:YES];
}

- (void)delayedResumeExpensiveOperations
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resumeExpensiveOperations) object:nil];
	[self performSelector:@selector(resumeExpensiveOperations) withObject:nil afterDelay:0.4];	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [[touches allObjects] objectAtIndex:0];
	//Check if the touch hit a RMMarker subclass and if so, forward the touch event on
	//so it can be handled there
	id furthestLayerDown = [self.contents.overlay hitTest:[touch locationInView:self]];
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
	
	//	RMLog(@"touchesBegan %d", [[event allTouches] count]);
	lastGesture = [self gestureDetails:[event allTouches]];

	if(deceleration)
	{
		if (_decelerationTimer != nil) {
			[self stopDeceleration];
		}
	}
	
	[self delayedResumeExpensiveOperations];
}

/// \bug touchesCancelled should clean up, not pass event to markers
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [[touches allObjects] objectAtIndex:0];
	
	//Check if the touch hit a RMMarker subclass and if so, forward the touch event on
	//so it can be handled there
	id furthestLayerDown = [self.contents.overlay hitTest:[touch locationInView:self]];
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
	id furthestLayerDown = [self.contents.overlay hitTest:[touch locationInView:self]];
	if ([[furthestLayerDown class]isSubclassOfClass: [RMMarker class]]) {
		if ([furthestLayerDown respondsToSelector:@selector(touchesEnded:withEvent:)]) {
			[furthestLayerDown performSelector:@selector(touchesEnded:withEvent:) withObject:touches withObject:event];
			return;
		}
	}
	NSInteger lastTouches = lastGesture.numTouches;
	
	// Calculate the gesture.
	lastGesture = [self gestureDetails:[event allTouches]];

    BOOL decelerating = NO;
	if (touch.tapCount >= 2)
	{
		if (_delegateHasDoubleTapOnMap) {
			[delegate doubleTapOnMap: self At: lastGesture.center];
		} else {
			// Default behaviour matches built in maps.app
			float nextZoomFactor = [self.contents nextNativeZoomFactor];
			if (nextZoomFactor != 0)
				[self zoomByFactor:nextZoomFactor near:[touch locationInView:self] animated:YES];
		}
	} else if (lastTouches == 1 && touch.tapCount != 1) {
		// deceleration
		if(deceleration && enableDragging)
		{
			CGPoint prevLocation = [touch previousLocationInView:self];
			CGPoint currLocation = [touch locationInView:self];
			CGSize touchDelta = CGSizeMake(currLocation.x - prevLocation.x, currLocation.y - prevLocation.y);
			[self startDecelerationWithDelta:touchDelta];
            decelerating = YES;
		}
	}
	
    
	// If there are no more fingers on the screen, resume any slow operations.
	if (lastGesture.numTouches == 0 && !decelerating)
	{
        [self delayedResumeExpensiveOperations];
	}
    
	
	if (touch.tapCount == 1) 
	{
		if(lastGesture.numTouches == 0)
		{
			CALayer* hit = [self.contents.overlay hitTest:[touch locationInView:self]];
			//		RMLog(@"LAYER of type %@",[hit description]);
			
			if (hit != nil) {
				CALayer *superlayer = [hit superlayer]; 
				
				// See if tap was on a marker or marker label and send delegate protocol method
				if ([hit isKindOfClass: [RMMarker class]]) {
					if (_delegateHasTapOnMarker) {
						[delegate tapOnMarker:(RMMarker*)hit onMap:self];
					}
				} else if (superlayer != nil && [superlayer isKindOfClass: [RMMarker class]]) {
					if (_delegateHasTapOnLabelForMarker) {
						[delegate tapOnLabelForMarker:(RMMarker*)superlayer onMap:self];
					}
				} else if ([superlayer superlayer] != nil && [[superlayer superlayer] isKindOfClass: [RMMarker class]]) {
                                        if (_delegateHasTapOnLabelForMarker) {
                                                [delegate tapOnLabelForMarker:(RMMarker*)[superlayer superlayer] onMap:self];
                                        } 
				} else if (_delegateHasSingleTapOnMap) {
					[delegate singleTapOnMap: self At: [touch locationInView:self]];
				}
			}
		}
		else if(!enableDragging && (lastGesture.numTouches == 1))
		{
			float prevZoomFactor = [self.contents prevNativeZoomFactor];
			if (prevZoomFactor != 0)
				[self zoomByFactor:prevZoomFactor near:[touch locationInView:self] animated:YES];
		}
	}
	
	if (_delegateHasAfterMapTouch) [delegate afterMapTouch: self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [[touches allObjects] objectAtIndex:0];
	
	//Check if the touch hit a RMMarker subclass and if so, forward the touch event on
	//so it can be handled there
	id furthestLayerDown = [self.contents.overlay hitTest:[touch locationInView:self]];
	if ([[furthestLayerDown class]isSubclassOfClass: [RMMarker class]]) {
		if ([furthestLayerDown respondsToSelector:@selector(touchesMoved:withEvent:)]) {
			[furthestLayerDown performSelector:@selector(touchesMoved:withEvent:) withObject:touches withObject:event];
			return;
		}
	}
	
	CALayer* hit = [self.contents.overlay hitTest:[touch locationInView:self]];
//	RMLog(@"LAYER of type %@",[hit description]);
	
	if (hit != nil) {
   
      if ([hit isKindOfClass: [RMMarker class]]) {
   
         if (!_delegateHasShouldDragMarker || (_delegateHasShouldDragMarker && [delegate mapView:self shouldDragMarker:(RMMarker*)hit withEvent:event])) {
            if (_delegateHasDidDragMarker) {
               [delegate mapView:self didDragMarker:(RMMarker*)hit withEvent:event];
               return;
            }
         }
      }
	}
	
	RMGestureDetails newGesture = [self gestureDetails:[event allTouches]];
	
	if(enableRotate && (newGesture.numTouches == lastGesture.numTouches))
	{
          if(newGesture.numTouches == 2)
          {
		CGFloat angleDiff = lastGesture.angle - newGesture.angle;
		CGFloat newAngle = self.rotation + angleDiff;
		
		[self setRotation:newAngle];
          }
	}
	
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
	
	[self delayedResumeExpensiveOperations];
}

// first responder needed to use UIMenuController
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark Deceleration

- (void)startDecelerationWithDelta:(CGSize)delta {
	if (ABS(delta.width) >= 1.0f && ABS(delta.height) >= 1.0f) {
		_decelerationDelta = delta;
        if ( !_decelerationTimer ) {
            _decelerationTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f 
                                                                 target:self
                                                               selector:@selector(incrementDeceleration:) 
                                                               userInfo:nil 
                                                                repeats:YES];
        }
	}
}

- (void)incrementDeceleration:(NSTimer *)timer {
	if (ABS(_decelerationDelta.width) < kMinDecelerationDelta && ABS(_decelerationDelta.height) < kMinDecelerationDelta) {
		[self stopDeceleration];

        // Resume any slow operations after deceleration completes
        [self delayedResumeExpensiveOperations];
        
		return;
	}

	// avoid calling delegate methods? design call here
	[self.contents moveBy:_decelerationDelta];

	_decelerationDelta.width *= [self decelerationFactor];
	_decelerationDelta.height *= [self decelerationFactor];
}

- (void)stopDeceleration {
	if (_decelerationTimer != nil) {
		[_decelerationTimer invalidate];
		_decelerationTimer = nil;
		_decelerationDelta = CGSizeZero;

		// call delegate methods; design call (see above)
		[self moveBy:CGSizeZero];
	}
}

/// Must be called by higher didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
	LogMethod();
	[contents didReceiveMemoryWarning];
}

- (void)setFrame:(CGRect)frame
{
  CGRect r = self.frame;
  [super setFrame:frame];
  // only change if the frame changes AND there is contents
  if (!CGRectEqualToRect(r, frame) && contents) {
    [contents setFrame:frame];
  }
}

- (void)setRotation:(CGFloat)angle
{
 	if (_delegateHasBeforeMapRotate) [delegate beforeMapRotate: self fromAngle: rotation];

	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:0.0f] forKey:kCATransactionAnimationDuration];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	rotation = angle;
		
	self.transform = CGAffineTransformMakeRotation(rotation);
	[contents setRotation:rotation];	
	
	[CATransaction commit];

 	if (_delegateHasAfterMapRotate) [delegate afterMapRotate: self toAngle: rotation];
}

@end
