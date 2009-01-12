//
//  MapView.m
//  freemap-iphone
//
//  Created by Michel Barakat on 10/20/08.
//  Copyright 2008 Høgskolen i Østfold. All rights reserved.
//

#import "MapView.h"

@implementation MapView

@synthesize mapContentView;
@synthesize mapState;

- (id)initWithCoder:(NSCoder*)coder {
	if (self = [super initWithCoder:coder]) {
		// Initialization code
    NSLog(@"MapView::initWithCoder");
    NSString *tmpText;
    tmpText = [[NSUserDefaults standardUserDefaults] 
               stringForKey:@"base_layer"];
    int baseLayer = [tmpText integerValue];
    
    tmpText = [[NSUserDefaults standardUserDefaults] 
               stringForKey:@"cache_size"];
    int cacheSize = [tmpText integerValue];
    
    NSLog(@"Preferences baseLayer: %d cacheSize: %d", baseLayer, cacheSize);
    
		// TODO: Map Source and location should be fetched from settings or
		// earlier run of application.
		MapSource *mapSource = [[MapSource alloc] 
                            initWithMapDataSource:baseLayer];

    // Load map state if saved earlier.
    BOOL stateLoaded = [self loadMapStateWithSource:mapSource];
    
    // Use default location otherwise.
    if (!stateLoaded) {
      // Default location: Dusseldorf zoom 15.
      const CGFloat startLatitude = 51.223751;
      const CGFloat startLongitude = 6.778393;
      const int startZoom = 15;
      
      MapCoordinates *startCoordinates = [[MapCoordinates alloc] 
                       initWithLatitude:startLatitude Longitude:startLongitude];
      mapState = [[MapState alloc] initWithMapSource:mapSource 
                                  CenteredAt:startCoordinates AtZoom:startZoom];
      [startCoordinates release];  
    }
    
		[mapSource release];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	NSLog(@"MapView::initWithFrame");
	if (self = [super initWithFrame:frame]) {
		// Initialization code
	}
	return self;
}


- (void)drawRect:(CGRect)rect {
	NSLog(@"MapView::drawRect");
	// Drawing code
  
	[mapState setScreenViewportSize:[mapContentView screenViewPortSize] 
            AndMemoryViewportSize:[mapContentView memoryViewPortSize]];
	[mapContentView showMapInState:mapState];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"MapView::touchesBegan");
	
	const NSSet *allTouches = [event allTouches];
  
	switch ([allTouches count]) {
   case 1:
      ; // fixes compiler bug
      // Single touch
      //NSLog(@"One Touch");
      const UITouch *touch = [allTouches anyObject];
      
      if ([touch tapCount] == 1) {
        //NSLog(@"Single tap");
        userAction = UA_MOVE;
        lastTouchLocation = [touch locationInView:touch.view];	
        [mapContentView initMoveMap];
      } else {
        //NSLog(@"Multi tap");
        userAction = UA_MOVE_TO_POINT;
        lastTouchLocation = [touch locationInView:touch.view];	
        [mapContentView initMoveMap];
      }
   break;
   case 2:
      // Double touch
      //NSLog(@"Two touch");
      userAction = UA_ZOOM;
      
      UITouch *firstTouch = [[allTouches allObjects] objectAtIndex:0];
      UITouch *secondTouch = [[allTouches allObjects] objectAtIndex:1];
      
      const CGPoint firstPoint = [firstTouch locationInView:firstTouch.view];
      const CGPoint secondPoint = [secondTouch locationInView:secondTouch.view];
      lastDistance = [MapView euclideanDistanceFromPoint:firstPoint 
                                                 ToPoint:secondPoint];
      zoomScaleFactor = 1.0;
      [mapContentView initZoom];
   break;
   }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	//NSLog(@"MapView::touchesMoved");

	const NSSet *allTouches = [event allTouches];
  
  switch (userAction) {
    case UA_MOVE:
      ; // fixes compiler bug
      UITouch *touch = [allTouches anyObject];
      const CGPoint touchLocation = [touch locationInView:touch.view];
      const CGPoint transition = 
        CGPointMake(touchLocation.x - lastTouchLocation.x, 
                    touchLocation.y - lastTouchLocation.y);
      [mapContentView moveMap:transition];
      lastTouchLocation = touchLocation;
    break;
    case UA_MOVE_TO_POINT:
      // Nothing to do in this case.
    break;
    case UA_ZOOM:
      ; // fixes compiler bug
      // Takes care of case where user uses two touches then release one touch.
      if ([[allTouches allObjects] count] != 2) {
        break;
      }
      UITouch *firstTouch = [[allTouches allObjects] objectAtIndex:0];
      UITouch *secondTouch = [[allTouches allObjects] objectAtIndex:1];
      
      const CGPoint firstPoint = [firstTouch locationInView:firstTouch.view];
      const CGPoint secondPoint = [secondTouch locationInView:secondTouch.view];
      CGFloat currentDistance = [MapView euclideanDistanceFromPoint:firstPoint 
                                                           ToPoint:secondPoint];
      
      if (lastDistance > currentDistance) {
        zoomScaleFactor = zoomScaleFactor * 
          (1 - ((lastDistance - currentDistance) / lastDistance));
      } else if (lastDistance < currentDistance) {
        zoomScaleFactor = zoomScaleFactor * 
          (1 + ((currentDistance - lastDistance) / currentDistance));
      }
      
      [mapContentView zoomOnMapWithScaleFactor:zoomScaleFactor];
      lastDistance = currentDistance;
    break;
  }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"MapView::touchesEnded");
  
  switch (userAction) {
    case UA_MOVE:
      [mapContentView showMapInState:mapState];
    break;
    case UA_MOVE_TO_POINT:
      [mapContentView moveMapToCenter:lastTouchLocation];
      [mapContentView showMapInState:mapState];
    break;
    case UA_ZOOM:
      ; // fixes compiler bug
      MapState *newMapState = [mapContentView 
                               mapStateAtZoomScaleFactor:zoomScaleFactor 
                               FromInitialMapState:mapState];
      if (newMapState) {
        [mapState release];
        mapState = newMapState;
        [mapContentView showMapInState:mapState];
      }
    break;
  }
}

- (BOOL) loadMapStateWithSource:(MapSource*) mapSource {
  NSString *fileName = [NSString stringWithFormat:@"%@/Documents/location.txt", 
                        NSHomeDirectory()];
  NSString *location = [NSString stringWithContentsOfFile:fileName 
                                     encoding:NSASCIIStringEncoding error:NULL];
  if (location == 0) {
    return false;
  }
  
  NSArray* locationCoordinates = [location componentsSeparatedByString:@"\n"];
  assert([locationCoordinates count] == 3);
  
  const CGFloat latitude = [[locationCoordinates objectAtIndex:0] floatValue];
  const CGFloat longitude = [[locationCoordinates objectAtIndex:1] 
                             floatValue];
  const int zoom = [[locationCoordinates objectAtIndex:2] integerValue];
  MapCoordinates* mapCoordinates =
    [[MapCoordinates alloc] initWithLatitude:latitude Longitude:longitude];
  mapState = [[MapState alloc] initWithMapSource:mapSource 
                                      CenteredAt:mapCoordinates AtZoom:zoom];
  [mapCoordinates release];
  
  return true;
}

- (void)saveMapState {
  // MapState coordinates might not be the latest.
  MapCoordinates* freshMapCoords = [mapContentView computeCenterMapCoordinates];
  
  NSString* currentLocation = [[NSString alloc] initWithFormat:@"%f\n%f\n%d", 
                             freshMapCoords.latitude, freshMapCoords.longitude,
                             [mapState zoom]];
  [freshMapCoords release];
  
  NSString *fileName = [NSString stringWithFormat:@"%@/Documents/location.txt", 
                        NSHomeDirectory()];
  assert([currentLocation writeToFile:fileName atomically:TRUE 
                             encoding:NSASCIIStringEncoding error:NULL]);
}

- (void)dealloc {
	[mapState release];
	[super dealloc];
}

+ (CGFloat)euclideanDistanceFromPoint:(CGPoint)firstPoint
                              ToPoint:(CGPoint)secondPoint {
  float x = secondPoint.x - firstPoint.x;
  float y = secondPoint.y - firstPoint.y;
  
  return sqrt(x * x + y * y);
}

@end

