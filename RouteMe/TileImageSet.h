//
//  TileImageSet.h
//  RouteMe
//
//  Created by Joseph Gentle on 9/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tile.h"

@class TileImage;

@protocol TileImageSetDelegate<NSObject>

-(TileImage*) makeTileImageFor:(Tile) tile;

@optional

-(void) tileRemoved: (Tile) tile;
-(void) tileAdded: (Tile) tile WithImage: (TileImage*) image;

@end

@interface TileImageSet : NSObject {
	IBOutlet id<TileImageSetDelegate> delegate;
	NSCountedSet *images;
	// This fixes an image resizing bug which causes thin lines along image borders
	BOOL nudgeTileSize;
}

-(id) initWithDelegate: (id<TileImageSetDelegate>) _delegate;

-(void) addTile: (Tile) tile WithImage: (TileImage *)image At: (CGRect) screenLocation;
-(void) addTile: (Tile) tile At: (CGRect) screenLocation;
// Add tiles inside rect protected to bounds. Return rectangle containing bounds
// extended to full tile loading area
-(CGRect) addTiles: (TileRect)rect ToDisplayIn:(CGRect)bounds;

-(TileImage*) imageWithTile: (Tile) tile;

-(void) removeTile: (Tile) tile;
-(void) removeTiles: (TileRect)rect;

-(NSUInteger) count;

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center;

- (void) draw;

@property (assign, nonatomic, readwrite) id<TileImageSetDelegate> delegate;
@property (readwrite, assign, nonatomic) BOOL nudgeTileSize;

@end
