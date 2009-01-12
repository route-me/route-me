//
//  MapView.h
//  freemap-iphone
//
//  Created by Michel Barakat on 10/20/08.
//  Copyright 2008 Høgskolen i Østfold. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MapContentView.h"
#import "MapState.h"
#import "MapSource.h"

enum UserAction {
  UA_MOVE = 0,
  UA_MOVE_TO_POINT,
  UA_ZOOM
};

@interface MapView : UIView {
  
@private
	IBOutlet MapContentView *mapContentView;
	MapState* mapState;
	
	CGPoint lastTouchLocation;
  CGFloat lastDistance;
  CGFloat zoomScaleFactor;
  
  enum UserAction userAction;
}

@property (retain) MapContentView *mapContentView;
@property (readonly, retain) MapState *mapState;

- (void)saveMapState;

// Private
- (BOOL) loadMapStateWithSource:(MapSource*) mapSource;
+ (CGFloat)euclideanDistanceFromPoint:(CGPoint)firstPoint
                              ToPoint:(CGPoint)secondPoint;

@end
