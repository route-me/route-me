//
//  MapContentView.h
//  freemap-iphone
//
//  Created by Michel Barakat on 10/20/08.
//  Copyright 2008 Høgskolen i Østfold. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MapState.h"
#import "MapTile.h"

@interface MapContentView : UIView {
	CGSize screenViewPortSize;
	CGSize memoryViewPortSize;
}

@property(readonly) CGSize screenViewPortSize;
@property(readonly) CGSize memoryViewPortSize;

- (void)showMapInState:(MapState*) mapState;

- (void)initMoveMap;
- (void)moveMap:(CGPoint) transition;
- (void)moveMapToCenter:(CGPoint) newCenterPoint;

- (void)initZoom;
- (void)zoomOnMapWithScaleFactor:(CGFloat) scaleFactor;
- (MapState*)mapStateAtZoomScaleFactor:(CGFloat) scaleFactor 
                   FromInitialMapState:(MapState*) initialMapState;

// Private
- (void)populateTiles:(MapTile*) startTile;
- (void)removeOutOfScopeTiles;
- (MapCoordinates*)computeCenterMapCoordinates;

@end
