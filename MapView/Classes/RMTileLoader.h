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

@class RMTileImage;
@class RMTileImageSet;
@class RMScreenProjection;

extern NSString * const MapImageRemovedFromScreenNotification;

@protocol RMTileSource;

@interface RMTileLoader : NSObject <RMTileImageSetDelegate> {
	// Set of locatedtileimages
	RMTileImageSet *images;
//	NSMutableSet *buffer;
//	BOOL dirty;
	
	RMScreenProjection* screenProjection;
	id<RMTileSource> tileSource;
	
	CGRect loadedBounds;
	int loadedZoom;
	RMTileRect loadedTiles;
}

// Designated initialiser
-(id) initForScreen: (RMScreenProjection*)screen FromImageSource: (id<RMTileSource>)source;

//-(id) initFromRect:(TileRect) rect FromImageSource: (id<TileSource>)source ToDisplayIn:(CGRect)bounds WithTileDelegate: (id)delegate;
-(void) dealloc;

// Invalidate all current image data.
//-(void) setNeedsRedraw;

//-(BOOL) needsRedraw;
-(void) assemble;

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center;

-(void) clearLoadedBounds;

@property (readonly, nonatomic) CGRect loadedBounds;
@property (readonly, nonatomic) int loadedZoom;

-(BOOL) containsRect: (CGRect)bounds;

//-(void) assembleFromRect:(TileRect) rect FromImageSource: (id<TileSource>)source ToDisplayIn:(CGRect)bounds WithTileDelegate: (id)delegate;
-(void) draw;

@end
