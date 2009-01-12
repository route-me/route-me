//
//  MapContentView.m
//  freemap-iphone
//
//  Created by Michel Barakat on 10/20/08.
//  Copyright 2008 Høgskolen i Østfold. All rights reserved.
//

#import "MapContentView.h"
#import "MapLoader.h"
#import "MapSource.h"
#import "MapTools.h"

@implementation MapContentView

@synthesize screenViewPortSize;
@synthesize memoryViewPortSize;

- (id)initWithCoder:(NSCoder*)coder {
	NSLog(@"MapContentView::initWithCoder");
	if (self = [super initWithCoder:coder]) {
		// Initialization code
		// TODO: Manual input here because MapContentView::drawRect is executed 
		// after MapContentView::showMapInState.
		const double SCREEN_WIDTH = 320.0;
		const double SCREEN_HEIGHT = 416.0;
		const double MEMORY_WIDTH_OFFSET = 50.0;  // default 50.0
		const double MEMORY_HEIGHT_OFFSET = 50.0; // default 50.0
		
		screenViewPortSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
		
		// Memory viewport determines which tiles outside the screen viewport
		// should be kept loaded in memory.
		memoryViewPortSize =
			CGSizeMake(screenViewPortSize.width + 2 * MEMORY_WIDTH_OFFSET,
					   screenViewPortSize.height + 2 * MEMORY_HEIGHT_OFFSET);
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	NSLog(@"MapContentView::initWithFrame");
	if (self = [super initWithFrame:frame]) {
		// Initialization code
	}
	return self;
}


- (void)drawRect:(CGRect)rect {
	NSLog(@"MapContentView::drawRect");
	// Drawing code
	assert(screenViewPortSize.width == rect.size.width);
	assert(screenViewPortSize.height == rect.size.height);
}

- (void)showMapInState:(MapState*) mapState {
	NSLog(@"MapContentView::showMapInState");
	assert(mapState != 0);
	
	[self removeOutOfScopeTiles];
  [MapLoader resumeFetching];
  
	if ([[self subviews] count] == 0) {
		const CGPoint mapTileXY = [MapTools mapTileXYFromMapCoordinates:
								[mapState centerCoords] AtZoom:[mapState zoom]];
    
		MapTile *mainTile = [[MapTile alloc] initWithX:mapTileXY.x Y:mapTileXY.y 
                                        InMapState:mapState];
    
		const CGPoint tileCenterOffset =	
			[MapTools tileCenterOffsetFromMapTile:mainTile];
		CGPoint tileCenter = 
			CGPointMake((screenViewPortSize.width / 2) - tileCenterOffset.x,
						(screenViewPortSize.height / 2) - tileCenterOffset.y);
	
		mainTile.center = tileCenter;
		[self addSubview:mainTile];
	} else {
    NSLog(@"MapTiles in View: %d", [[self subviews] count]);
	}
  
  // Populate all tiles in the content view.
  // Condition is updated on every iteration.
  for (int i = 0; i < [[self subviews] count]; ++i) { 
    MapTile *mapTile = [[self subviews] objectAtIndex:i];
    [self populateTiles:mapTile];
  }
}
- (void)initMoveMap {
  [MapLoader pauseFetching];
}

- (void)moveMap:(CGPoint) transition {
	//NSLog(@"MapContentView::moveMap");
  
	for (int i = 0; i < [[self subviews] count]; ++i) {
		MapTile *mapTile = [[self subviews] objectAtIndex:i];
		mapTile.center = CGPointMake(mapTile.center.x + transition.x, 
									 mapTile.center.y + transition.y);
		mapTile.transform = CGAffineTransformIdentity;
	}
  
  // Note: Coordinates in MapState are updated only when needed 
  // (eg. before zooming).
}

- (void)moveMapToCenter:(CGPoint) newCenterPoint {
  NSLog(@"MapContentView::moveMapToCenter");
  
  const CGPoint transition = 
    CGPointMake([self center].x - newCenterPoint.x, 
                [self center].y - newCenterPoint.y);
  
  [self moveMap:transition];
}

- (void)initZoom {
  [MapLoader pauseFetching]; 
}

- (void)zoomOnMapWithScaleFactor:(CGFloat) scaleFactor {
  //NSLog(@"MapContentView::zoomOnMapWithScaleFactor"); // remove
  
  if (scaleFactor < 0.25) {
    scaleFactor = 0.25;
  } else if (scaleFactor > 4.0) {
    scaleFactor = 4.0;
  }
  self.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
}

- (MapState*)mapStateAtZoomScaleFactor:(CGFloat) scaleFactor 
                   FromInitialMapState:(MapState*) initialMapState {
  assert(initialMapState != 0);
  //NSLog(@"MapContentView::endZoomOnMapWithScaleFactor"); // remove
  
  if (scaleFactor < 0.50) {
    scaleFactor = 0.25;
  } else if (scaleFactor < 0.85) {
    scaleFactor = 0.50;
  } else if (scaleFactor < 1.30) {
    scaleFactor = 1.0;
  } else if (scaleFactor <= 2.0) {
    scaleFactor = 2.0;    
  } else if (scaleFactor > 2.0) {
    scaleFactor = 4.0;
  }
  
  const int curZoom = [initialMapState zoom];
  const int minZoom = [[initialMapState mapSource] minZoom];
  const int maxZoom = [[initialMapState mapSource] maxZoom];
  
  int newZoom = curZoom;
  // Checking that zooming in or out is possible.
  if (scaleFactor < 1.0) {
    // Zooming out.
    if (scaleFactor == 0.25) {
      if ((curZoom - 2) < minZoom) {
        scaleFactor = 0.50;
      } else {
        newZoom -= 2;
      }
    }
  
    if (scaleFactor == 0.50) {
      if ((curZoom - 1) < minZoom) {
        scaleFactor = 1.0;
      } else {
        newZoom -= 1;
      }
    }
  } else if (scaleFactor > 1.0) {
    // Zooming in.
    if (scaleFactor == 4.0) {
      if ((curZoom + 2) > maxZoom) {
        scaleFactor = 2.0;
      } else {
        newZoom += 2;
      }
    }
    
    if (scaleFactor == 2.0) {
      if ((curZoom + 1) > maxZoom) {
        scaleFactor = 1.0;
      } else {
        newZoom += 1;
      }
    }
  }
  
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
  self.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
  [UIView commitAnimations];

  MapCoordinates *newMapCoords = [self computeCenterMapCoordinates];
  
  if (scaleFactor == 1.0) {
    [MapLoader resumeFetching];
    [initialMapState setCenterCoords:newMapCoords];
    
    [newMapCoords release];
    
    return 0;
  } else {    
    MapState *newMapState = [[MapState alloc] 
                             initWithMapSource:[initialMapState mapSource] 
                             CenteredAt:newMapCoords 
                             AtZoom:newZoom];
    [newMapState setScreenViewportSize:screenViewPortSize 
                 AndMemoryViewportSize:memoryViewPortSize];
    
    [newMapCoords release];
    
    // Remove all tiles in view.
		for (int i = 0; i < [[self subviews] count]; ++i) {
			MapTile *mapTile = [[self subviews] objectAtIndex:i];
      [MapLoader stopMapTileFetch:mapTile];
			[mapTile destroy];
			[mapTile release];
      --i; // tile has already been removed.
		}
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1];
    self.transform = CGAffineTransformMakeScale(1.0, 1.0);
    [UIView commitAnimations];
    
    return newMapState;
  }
  
}

- (void)dealloc {
	[super dealloc];
}

- (void)populateTiles:(MapTile*) startTile {
	//NSLog(@"MapContentView::populateTiles");
	assert(startTile != 0);
  
	const struct BoxBoundary screenBoundary = 
  [[startTile mapState] screenViewportBoundary];
	
	const double tileWidth = startTile.frame.size.width;
	const double tileHeight = startTile.frame.size.height;
	const double tileHalfWidth = tileWidth / 2;
	const double tileHalfHeight = tileHeight / 2;
  
	// North tile.
	if ((startTile.center.y - tileHalfHeight) > screenBoundary.north &&
      ![startTile hasNorthTile]) {
		MapTile* northTile = [startTile makeNorthTile];
		const CGPoint center = CGPointMake(startTile.center.x, 
                                       startTile.center.y - tileHeight);
		northTile.center = center;
		[self addSubview:northTile];
	}
	
	// South tile.
	if ((startTile.center.y + tileHalfHeight) < screenBoundary.south &&
      ![startTile hasSouthTile]) {
		MapTile* southTile = [startTile makeSouthTile];
		const CGPoint center = CGPointMake(startTile.center.x, 
                                       startTile.center.y + tileHeight);
		southTile.center = center;
		[self addSubview:southTile];
	}
  
	// West tile.
	if ((startTile.center.x - tileHalfWidth) > screenBoundary.west &&
      ![startTile hasWestTile]) {
		MapTile* westTile = [startTile makeWestTile];
		const CGPoint center = CGPointMake(startTile.center.x - tileWidth, 
                                       startTile.center.y);
		westTile.center = center;
		[self addSubview:westTile];
	}
  
	// East tile.
	if ((startTile.center.x + tileHalfWidth) < screenBoundary.east &&
      ![startTile hasEastTile]) {
		MapTile* eastTile = [startTile makeEastTile];
		const CGPoint center = CGPointMake(startTile.center.x + tileWidth, 
                                       startTile.center.y);
		eastTile.center = center;
		[self addSubview:eastTile];
	}
}

- (void)removeOutOfScopeTiles {
	NSLog(@"MapContentView::removeOutOfScopeTiles");
	
	struct BoxBoundary screenBoundary;
	struct BoxBoundary memoryBoundary;
	int tilesInScreen = [[self subviews] count];
	for (int i = 0; i < [[self subviews] count]; ++i) {
		MapTile *mapTile = [[self subviews] objectAtIndex:i];
		if (i == 0) {
			screenBoundary = [[mapTile mapState] screenViewportBoundary];
			memoryBoundary = [[mapTile mapState] memoryViewportBoundary];
		}
		
		const double north = mapTile.frame.origin.y;
		const double west = mapTile.frame.origin.x;
		const double south = mapTile.frame.origin.y + mapTile.frame.size.height;
		const double east = mapTile.frame.origin.x + mapTile.frame.size.width;
    
		// Remove tile outside memory boundary.
		if (south < memoryBoundary.north ||
        north > memoryBoundary.south ||
        west > memoryBoundary.east ||
        east < memoryBoundary.west) {
      [MapLoader stopMapTileFetch:mapTile];
			[mapTile destroy];
      [mapTile release];
      --i; // tile has already been removed.
		}		
		
		// Count number of tiles inside screen.
		if (south < screenBoundary.north ||
        north > screenBoundary.south ||
        west > screenBoundary.east ||
        east < screenBoundary.west) {
			tilesInScreen--;
		}
	}
  
	// HACK: If no tiles are within screen boundaries, remove all from memory.
	// Doing so limits us from falling in a situation where mapTiles are not 
	// linked.
	if (tilesInScreen == 0) {
		for (int i = 0; i < [[self subviews] count]; ++i) {
			MapTile *mapTile = [[self subviews] objectAtIndex:i];
      [MapLoader stopMapTileFetch:mapTile];
			[mapTile destroy];
			[mapTile release];
      --i; // tile has already been removed.
		}
	}
}

// Computes the current map coordinates in the view.
- (MapCoordinates*)computeCenterMapCoordinates {
  NSLog(@"MapContentView::computeCenterMapCoordinates");
  
  // Find map tile in center.
  const CGPoint viewCenter = CGPointMake((screenViewPortSize.width / 2), 
                                         (screenViewPortSize.height / 2));
  MapTile *centerMapTile = 0;
  CGSize tileSize;
  int xSide, ySide;
  for (int i = 0; i < [[self subviews] count]; ++i) {
    MapTile* mapTile = [[self subviews] objectAtIndex:i];
    
    if (i == 0) {
      tileSize = [[[mapTile mapState] mapSource] tileSize];
      xSide = tileSize.width / 2;
      ySide = tileSize.height / 2;
    }
    
    const CGPoint center = [mapTile center];
    if ((center.x >= (viewCenter.x - xSide)) && 
        (center.x < (viewCenter.x + xSide)) && 
        (center.y >= (viewCenter.y - ySide)) && 
        (center.y < (viewCenter.y + ySide))) {
      centerMapTile = mapTile;
      break;
    }
  }
  assert(centerMapTile != 0);
  
  // Compute coordinates of view center.
  BoundBox *boundBox = [MapTools boundBoxFromMapTile:centerMapTile];
  
  const CGFloat cmtNorthCoord = [centerMapTile center].y - ySide;
  const CGFloat viewCenterLatitude = [boundBox northLatitude] - 
    (((viewCenter.y - cmtNorthCoord) / tileSize.height) * 
     ([boundBox northLatitude] - [boundBox southLatitude]));
  
  const CGFloat cmtWestCoord = [centerMapTile center].x - xSide;
  const CGFloat viewCenterLongitude = 
    (((viewCenter.x - cmtWestCoord) / tileSize.width) * 
     ([boundBox eastLongitude] - [boundBox westLongitude])) + 
    [boundBox westLongitude];
  
  [boundBox release];
  
  MapCoordinates *newMapCoords = [[MapCoordinates alloc] 
                                  initWithLatitude:viewCenterLatitude 
                                  Longitude:viewCenterLongitude];
  return newMapCoords;
}

@end
