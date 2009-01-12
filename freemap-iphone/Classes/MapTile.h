//
//  MapTile.h
//  freemap-iphone
//
//  Created by Michel Barakat on 8/31/08.
//  Copyright 2008 Høgskolen i Østfold. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MapState.h"

@interface MapTile : UIImageView {
	
@private
	int x;
	int y;
	MapState* mapState;
	
	MapTile *northTile;
	MapTile *southTile;
	MapTile *eastTile;
	MapTile *westTile;
}

@property(readonly) int x;
@property(readonly) int y;
@property(readonly,assign) MapState* mapState;

@property(readwrite,assign,setter=setNorthTile:) MapTile *northTile;
@property(readwrite,assign,setter=setSouthTile:) MapTile *southTile;
@property(readwrite,assign,setter=setEastTile:) MapTile *eastTile;
@property(readwrite,assign,setter=setWestTile:) MapTile *westTile;

- (id)initWithX:(int)initX Y:(int)initY InMapState:(MapState*) initMapState;
- (int)zoom;

- (void)setNorthTile:(MapTile*) newNorthTile;
- (void)setSouthTile:(MapTile*) newSouthTile;
- (void)setEastTile:(MapTile*) newEastTile;
- (void)setWestTile:(MapTile*) newWestTile;

- (void)unsetNorthTile;
- (void)unsetSouthTile;
- (void)unsetEastTile;
- (void)unsetWestTile;

- (BOOL)hasNorthTile;
- (BOOL)hasSouthTile;
- (BOOL)hasEastTile;
- (BOOL)hasWestTile;

- (MapTile*)makeNorthTile;
- (MapTile*)makeSouthTile;
- (MapTile*)makeEastTile;
- (MapTile*)makeWestTile;

- (void)destroy;

@end
