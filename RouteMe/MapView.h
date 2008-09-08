//
//  MapView.h
//  Images
//
//  Created by Joseph Gentle on 13/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct {
	CGPoint center;
	float averageDistanceFromCenter;
} GestureDetails;

@class TileSource;
@class TiledLayerController;
//@class TileImageSet;

@interface MapView : UIView {
	id tileSource;
	TiledLayerController *screenProjection;
	float zoom;
	
	bool enableDragging;
	bool enableZoom;
//	double lastZoomDistance;
	
	// This is basically a one-object allocation pool.
//	TileImageSet *imageSet;
	
	GestureDetails lastGesture;
}

@property (assign, readwrite) bool enableDragging;
@property (assign, readwrite) bool enableZoom;

@end
