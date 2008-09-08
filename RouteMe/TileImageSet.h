//
//  TimeImageSet.h
//  Images
//
//  Created by Joseph Gentle on 29/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tile.h"

@class TileImage;
@protocol TileSource;

@interface TileImageSet : NSObject {
	// Set of locatedtileimages
	NSMutableSet *images;
	NSMutableSet *buffer;
//	BOOL dirty;
	
	CGRect loadedBounds;
	int loadedZoom;
	
	// This fixes an image resizing bug which causes thin lines along image borders
	BOOL nudgeTileSize;
}

-(id) initFromRect:(TileRect) rect FromImageSource: (id<TileSource>)source ToDisplayIn:(CGRect)bounds WithTileDelegate: (id)delegate;
-(void) dealloc;

// Invalidate all current image data.
//-(void) setNeedsRedraw;

//-(BOOL) needsRedraw;

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center;

@property (readonly, nonatomic) CGRect loadedBounds;
@property (readonly, nonatomic) int loadedZoom;
@property (readwrite, assign, nonatomic) BOOL nudgeTileSize;

-(BOOL) containsRect: (CGRect)bounds;

-(void) assembleFromRect:(TileRect) rect FromImageSource: (id<TileSource>)source ToDisplayIn:(CGRect)bounds WithTileDelegate: (id)delegate;
-(void) draw;

@end
