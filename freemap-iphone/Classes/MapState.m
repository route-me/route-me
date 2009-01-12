//
//  MapState.m
//  freemap-iphone
//
//  Created by Michel Barakat on 10/20/08.
//  Copyright 2008 Høgskolen i Østfold. All rights reserved.
//

#import "MapState.h"

@implementation MapState

@synthesize zoom;
@synthesize tilesPerSide;
@synthesize mapSource;
@synthesize centerCoords;

- (id)initWithMapSource:(MapSource*) initMapSource 
			 CenteredAt:(MapCoordinates*) initCenterCoords 
				 AtZoom:(int) initZoom {
	assert(initMapSource != 0);
	assert(initCenterCoords != 0);
	assert(initZoom >= [initMapSource minZoom] && 
		   initZoom <= [initMapSource maxZoom]);
  
	mapSource = [[MapSource alloc] 
				 initWithMapDataSource:[initMapSource mapDataSource]];
	
	centerCoords = [[MapCoordinates alloc] 
					initWithLatitude:[initCenterCoords latitude] 
					Longitude:[initCenterCoords longitude]];
	
	zoom = initZoom;
  tilesPerSide = (1 << zoom); // equivalent to 2^zoom.
	boundBoxesSet = FALSE;
	
	return self;
}

- (void)setScreenViewportSize:(CGSize) screenViewportSize 
	  AndMemoryViewportSize:(CGSize) memoryViewportSize {
	assert(!boundBoxesSet);
	assert(memoryViewportSize.width >= screenViewportSize.width && 
		   memoryViewportSize.height >= screenViewportSize.height);
	
	// Compute ScreenBoxBoundary.
	const double screenHalfHeight = screenViewportSize.height / 2;
	const double screenHalfWidth = screenViewportSize.width / 2;
	
	// IMPORTANT: Center point coordinate don't change.
	const CGPoint centerPoint = CGPointMake(screenHalfWidth, screenHalfHeight);
	
	screenBoxBoundary.north = centerPoint.y - screenHalfHeight;
	screenBoxBoundary.south = centerPoint.y + screenHalfHeight;
	screenBoxBoundary.west = centerPoint.x - screenHalfWidth;
	screenBoxBoundary.east = centerPoint.x + screenHalfWidth;

	// Compute MemoryBoxBoundary.
	const double memoryHalfHeight = memoryViewportSize.height / 2;
	const double memoryHalfWidth = memoryViewportSize.width / 2;

	memoryBoxBoundary.north = centerPoint.y - memoryHalfHeight;
	memoryBoxBoundary.south = centerPoint.y + memoryHalfHeight;
	memoryBoxBoundary.west = centerPoint.x - memoryHalfWidth;
	memoryBoxBoundary.east = centerPoint.x + memoryHalfWidth;
	
	boundBoxesSet = TRUE;
}

- (void)setCenterCoords:(MapCoordinates*) newCenterCoords {
	assert(newCenterCoords != 0);
	assert(boundBoxesSet);
	
	if (centerCoords != 0) {
		[centerCoords release];
	}
	
	centerCoords = [[MapCoordinates alloc] 
					initWithLatitude:[newCenterCoords latitude] 
					Longitude:[newCenterCoords longitude]];
}

- (struct BoxBoundary)screenViewportBoundary {
	assert(boundBoxesSet);
	return screenBoxBoundary;
}
- (struct BoxBoundary)memoryViewportBoundary {
	assert(boundBoxesSet);
	return memoryBoxBoundary;
}

- (void)dealloc {
	[mapSource release];
	[centerCoords release];
	[super dealloc];
}

@end
