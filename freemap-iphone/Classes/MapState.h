//
//  MapState.h
//  freemap-iphone
//
//  Created by Michel Barakat on 10/20/08.
//  Copyright 2008 Høgskolen i Østfold. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BoundBox.h"
#import "MapCoordinates.h"
#import "MapSource.h"

struct BoxBoundary {
	double north;
	double south;
	double east;
	double west;
};

@interface MapState : NSObject {
	
@private
	int zoom;
  int tilesPerSide; // number of tiles per side.
	
	struct BoxBoundary screenBoxBoundary;
	struct BoxBoundary memoryBoxBoundary;
	BOOL boundBoxesSet;
	
	MapSource* mapSource;
	MapCoordinates* centerCoords;
}

@property(readonly) int zoom;
@property(readonly) int tilesPerSide;
@property(readonly, getter=screenViewportBoundary) 
	struct BoxBoundary screenBoxBoundary;
@property(readonly, getter=memoryViewportBoundary) 
	struct BoxBoundary memoryBoxBoundary;
@property(readonly, copy) MapSource* mapSource;
@property(readwrite,copy, setter=setCenterCoords:) MapCoordinates* centerCoords;

- (id)initWithMapSource:(MapSource*) initMapSource 
			 CenteredAt:(MapCoordinates*) initCenterCoords 
				 AtZoom:(int) initZoom;

- (void)setScreenViewportSize:(CGSize) screenViewportSize 
	  AndMemoryViewportSize:(CGSize) memoryViewportSize;

- (void)setCenterCoords:(MapCoordinates*) newCenterCoords;

- (struct BoxBoundary)screenViewportBoundary;
- (struct BoxBoundary)memoryViewportBoundary;

@end
