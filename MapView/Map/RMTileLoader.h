//
//  TimeImageSet.h
//  Images
//
//  Created by Joseph Gentle on 29/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMTile.h"
#import "RMTileImageSet.h"
#import "RMMapContents.h"

@class RMTileImage;
@class RMTileImageSet;
@class RMMercatorToScreenProjection;

extern NSString * const RMMapImageRemovedFromScreenNotification;
extern NSString * const RMMapImageAddedToScreenNotification;

extern NSString * const RMSuspendExpensiveOperations;
extern NSString * const RMResumeExpensiveOperations;

@protocol RMTileSource;

@interface RMTileLoader : NSObject {
	RMMapContents *content;

	CGRect loadedBounds;
	int loadedZoom;
	RMTileRect loadedTiles;
	
	BOOL suppressLoading;
}

// Designated initialiser
-(id) initWithContent: (RMMapContents *)contents;

-(void) updateLoadedImages;

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center;

-(void) clearLoadedBounds;

@property (readonly, nonatomic) CGRect loadedBounds;
@property (readonly, nonatomic) int loadedZoom;
@property (readwrite, assign) BOOL suppressLoading;

//-(BOOL) containsRect: (CGRect)bounds;

@end
