//
//  MapView.h
//  Images
//
//  Created by Joseph Gentle on 13/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "MapRenderer.h"
//#import "TileSource.h"

typedef struct {
	CGPoint center;
	float averageDistanceFromCenter;
} GestureDetails;

@protocol TileSource;
@class MapRenderer;
//@class TileSource;
//@class TileImageSet;

@interface MapView : UIView {
	id<TileSource> tileSource;
	MapRenderer *renderer;
	
	bool enableDragging;
	bool enableZoom;
	
	GestureDetails lastGesture;
}

@property (assign, readwrite, nonatomic) bool enableDragging;
@property (assign, readwrite, nonatomic) bool enableZoom;
@property (retain, readwrite, nonatomic) id<TileSource> tileSource;

@end
