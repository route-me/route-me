//
//  TileImageSet.h
//  RouteMe
//
//  Created by Joseph Gentle on 9/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMTile.h"

@class RMTileImage;

@protocol RMTileImageSetDelegate<NSObject>

-(RMTileImage*) makeTileImageFor:(RMTile) tile;

@optional

-(void) tileRemoved: (RMTile) tile;
-(void) tileAdded: (RMTile) tile WithImage: (RMTileImage*) image;

@end

@interface RMTileImageSet : NSObject {
	IBOutlet id<RMTileImageSetDelegate> delegate;
	NSCountedSet *images;
	// This fixes an image resizing bug which causes thin lines along image borders
	BOOL nudgeTileSize;
}

-(id) initWithDelegate: (id<RMTileImageSetDelegate>) _delegate;

-(void) addTile: (RMTile) tile WithImage: (RMTileImage *)image At: (CGRect) screenLocation;
-(void) addTile: (RMTile) tile At: (CGRect) screenLocation;
// Add tiles inside rect protected to bounds. Return rectangle containing bounds
// extended to full tile loading area
-(CGRect) addTiles: (RMTileRect)rect ToDisplayIn:(CGRect)bounds;

-(RMTileImage*) imageWithTile: (RMTile) tile;

-(void) removeTile: (RMTile) tile;
-(void) removeTiles: (RMTileRect)rect;

-(NSUInteger) count;

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center;

- (void) draw;

@property (assign, nonatomic, readwrite) id<RMTileImageSetDelegate> delegate;
@property (readwrite, assign, nonatomic) BOOL nudgeTileSize;

@end
