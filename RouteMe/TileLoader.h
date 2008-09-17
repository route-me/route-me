//
//  TimeImageSet.h
//  Images
//
//  Created by Joseph Gentle on 29/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tile.h"
#import "TileImageSet.h"

@class TileImage;
@class TileImageSet;
@class ScreenProjection;

extern NSString * const MapImageRemovedFromScreenNotification;

@protocol TileSource;

@interface TileLoader : NSObject <TileImageSetDelegate> {
	// Set of locatedtileimages
	TileImageSet *images;
//	NSMutableSet *buffer;
//	BOOL dirty;
	
	ScreenProjection* screenProjection;
	id<TileSource> tileSource;
	
	CGRect loadedBounds;
	int loadedZoom;
	TileRect loadedTiles;
}

// Designated initialiser
-(id) initForScreen: (ScreenProjection*)screen FromImageSource: (id<TileSource>)source;

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
