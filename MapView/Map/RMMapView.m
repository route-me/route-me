//
//  RMMapView.m
//  MapView
//
//  Created by Joseph Gentle on 24/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMMapView.h"
#import "RMMapContents.h"

#import "RMTileLoader.h"

#import "RMMercatorToScreenProjection.h"
#import "RMMarker.h"

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

#pragma mark Movement

-(void) moveToMercator: (RMMercatorPoint) point
{
	// TODO Add delegate hooks
	[contents moveToMercator:point];
}
-(void) moveToLatLong: (CLLocationCoordinate2D) point
{
	// TODO Add delegate hooks
	[contents moveToLatLong:point];
}

- (void)moveBy: (CGSize) delta
{
	// TODO Add delegate hooks
	[contents moveBy:delta];
}
- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center
{
	// TODO Add delegate hooks
	[contents zoomByFactor:zoomFactor Near:center];
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
	//*************************************************************************************
	//Double-tap detection (currently used for debugging pixelToLatLng() method)
	if (touch.tapCount == 2)
	{
		NSLog(@"***************************************************");
		NSLog(@"Begin double-tap pixel/LatLng translation debug test");
		CGPoint pixel = [touch locationInView:self];
		NSLog(@"Double-tap detected at: x=%f, y=%f", pixel.x, pixel.y);
		CLLocationCoordinate2D touchLatLng = [self pixelToLatLng:pixel];
		
		NSLog(@"Double-tap (x=%f, y=%f) is equivalent to: %f, %f", pixel.x, pixel.y, touchLatLng.latitude, touchLatLng.longitude);
		
		RMMercatorPoint merc = [[contents mercatorToScreenProjection] projectScreenPointToMercator:pixel];
		NSLog(@"Which is mercator %f %f", merc.x, merc.y);
		
		CLLocationCoordinate2D point;
		point.latitude = touchLatLng.latitude;
		point.longitude = touchLatLng.longitude;
		CGPoint screenPoint = [self latLngToPixel:point];
		
		NSLog(@"Converted LatLng to Pixel says we tapped at: x=%f, y=%f", screenPoint.x, screenPoint.y);
		NSLog(@"***************************************************");
	}
	//***************************************************************************************
	
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
			[self zoomByFactor: zoomFactor Near: newGesture.center];
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

- (CGPoint)latLngToPixel:(CLLocationCoordinate2D)latlong
{
	return [contents latLngToPixel:latlong];
}
- (CLLocationCoordinate2D)pixelToLatLng:(CGPoint)pixel
{
	return [contents pixelToLatLng:pixel];
}

#pragma mark Manual Zoom
- (void)setZoom:(int)zoomInt
{
	[contents setZoom:zoomInt];
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

@end
