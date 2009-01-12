//
//  MapTile.m
//  freemap-iphone
//
//  Created by Michel Barakat on 8/31/08.
//  Copyright 2008 Høgskolen i Østfold. All rights reserved.
//

#import "MapTile.h"
#import "MapLoader.h"

@implementation MapTile

@synthesize x;
@synthesize y;
@synthesize mapState;

@synthesize northTile;
@synthesize southTile;
@synthesize eastTile;
@synthesize westTile;

- (id)initWithX:(int)initX Y:(int)initY InMapState:(MapState*) initMapState {
	assert(initMapState != 0);
  
  const int tilesPerSide = [initMapState tilesPerSide];
  // Keep X tile within range [0 max-X-Tiles].
  // This will cause earth to loop horizontally when moving.
  if (initX >= tilesPerSide) {
    initX = initX - tilesPerSide;
  } else if (initX < 0) {
    initX = initX + tilesPerSide;
  }
	
  // Keep Y tile within range [0 max-Y-Tiles]
  // This will cause earth to loop vertically as well.
  if (initY >= tilesPerSide) {
    initY = initY - tilesPerSide;
  } else if (initY < 0) {
    initY = initY + tilesPerSide;
  }
  
	x = initX;
	y = initY;
	mapState = initMapState;
	
	northTile = 0;
	southTile = 0;
	eastTile = 0;
	westTile = 0;
	
  MapSource *mapSource = [mapState mapSource];
  @synchronized(self) {
    [self initWithImage:[mapSource loadingImage]];
  }
  [MapLoader loadImageFromX:x Y:y InTile:self];
	
	return self;
}

- (int)zoom {
	assert(mapState != 0);
	return [mapState zoom];
}

- (void)setNorthTile:(MapTile*) newNorthTile {
	assert(newNorthTile != 0);
	assert([newNorthTile zoom] == [self zoom]);	
	northTile = newNorthTile;
}

- (void)setSouthTile:(MapTile*) newSouthTile {
	assert(newSouthTile != 0);
	assert([newSouthTile zoom] == [self zoom]);
	southTile = newSouthTile;
}


- (void)setEastTile:(MapTile*) newEastTile {
	assert(newEastTile != 0);
	assert([newEastTile zoom] == [self zoom]);
	eastTile = newEastTile;
}

- (void)setWestTile:(MapTile*) newWestTile {
	assert(newWestTile != 0);
	assert([newWestTile zoom] == [self zoom]);
	westTile = newWestTile;
}

- (void)unsetNorthTile {
	northTile = 0;
}

- (void)unsetSouthTile {
	southTile = 0;
}

- (void)unsetEastTile {
	eastTile = 0;
}

- (void)unsetWestTile {
	westTile = 0;
}

- (BOOL)hasNorthTile {
	return (northTile != 0);
}

- (BOOL)hasSouthTile {
	return (southTile != 0);
}

- (BOOL)hasEastTile {
	return (eastTile != 0);
}

- (BOOL)hasWestTile {
	return (westTile != 0);
}

- (MapTile*)makeNorthTile {
	// Delete previous north tile.
	if (northTile != 0) {
		[northTile release];
		northTile = 0;
	}
	
	northTile = [[MapTile alloc] initWithX:[self x] Y:[self y] - 1 
								InMapState:[self mapState]];
	[northTile setSouthTile:self];
	
	// Update West-North tile.
	if ([self hasWestTile] && [[self westTile] hasNorthTile]) {
		[[[self westTile] northTile] setEastTile:northTile];
		[northTile setWestTile:[[self westTile] northTile]];
	}
	
	// Update East-North tile.
	if ([self hasEastTile] && [[self eastTile] hasNorthTile]) {
		[[[self eastTile] northTile] setWestTile:northTile];
		[northTile setEastTile:[[self eastTile] northTile]];
	}
	
	return northTile;
}

- (MapTile*)makeSouthTile {
	// Delete previous south tile.
	if (southTile != 0) {
		[southTile release];
		southTile = 0;
	}
	
	southTile = [[MapTile alloc] initWithX:[self x] Y:[self y] + 1 
                              InMapState:[self mapState]];
	[southTile setNorthTile:self];
	
	// Update West-South tile.
	if ([self hasWestTile] && [[self westTile] hasSouthTile]) {
		[[[self westTile] southTile] setEastTile:southTile];
		[southTile setWestTile:[[self westTile] southTile]];
	}
	
	// Update East-South tile.
	if ([self hasEastTile] && [[self eastTile] hasSouthTile]) {
		[[[self eastTile] southTile] setWestTile:southTile];
		[southTile setEastTile:[[self eastTile] southTile]];
	}
	
	return southTile;
}

- (MapTile*)makeEastTile {
	// Delete previous west tile.
	if (eastTile != 0) {
		[eastTile release];
		eastTile = 0;
	}
	
	eastTile = [[MapTile alloc] initWithX:[self x] + 1 Y:[self y] 
                             InMapState:[self mapState]];
	[eastTile setWestTile:self];
	
	// Update North-East tile.
	if ([self hasNorthTile] && [[self northTile] hasEastTile]) {
		[[[self northTile] eastTile] setSouthTile:eastTile];
		[eastTile setNorthTile:[[self northTile] eastTile]];
	}
	
	// Update South-East tile.
	if ([self hasSouthTile] && [[self southTile] hasEastTile]) {
		[[[self southTile] eastTile] setNorthTile:eastTile];
		[eastTile setSouthTile:[[self southTile] eastTile]];
	}
	
	return eastTile;
}

- (MapTile*)makeWestTile {
	// Delete previous west tile.
	if (westTile != 0) {
		[westTile release];
		westTile = 0;
	}
	
	westTile = [[MapTile alloc] initWithX:[self x] - 1 Y:[self y] 
                             InMapState:[self mapState]];
	[westTile setEastTile:self];
	
	// Update North-West tile.
	if ([self hasNorthTile] && [[self northTile] hasWestTile]) {
		[[[self northTile] westTile] setSouthTile:westTile];
		[westTile setNorthTile:[[self northTile] westTile]];
	}
	
	// Update South-West tile.
	if ([self hasSouthTile] && [[self southTile] hasWestTile]) {
		[[[self southTile] westTile] setNorthTile:westTile];
		[westTile setSouthTile:[[self southTile] westTile]];
	}
	
	return westTile;
}

- (void)destroy {
  //NSLog(@"MapTile::destroy");
	[self removeFromSuperview];
	
	if ([self hasNorthTile]) {
		[[self northTile] unsetSouthTile];
	}
	
	if ([self hasSouthTile]) {
		[[self southTile] unsetNorthTile];
	}
	
	if ([self hasWestTile]) {
		[[self westTile] unsetEastTile];
	}
	
	if ([self hasEastTile]) {
		[[self eastTile] unsetWestTile];
	}
}

- (void)dealloc {	
	[super dealloc];
}

@end
