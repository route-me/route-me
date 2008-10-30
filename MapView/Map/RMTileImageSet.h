//
//  TileImageSet.h
//  RouteMe
//
//  Created by Joseph Gentle on 9/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#	import <UIKit/UIKit.h>
#else
#	import <Cocoa/Cocoa.h>
#endif
#import "RMTile.h"

@class RMTileImage;
@protocol RMTileSource;

@protocol RMTileImageSetDelegate<NSObject>

@optional

-(void) tileRemoved: (RMTile) tile;
-(void) tileAdded: (RMTile) tile WithImage: (RMTileImage*) image;

@end

@interface RMTileImageSet : NSObject {
	IBOutlet id delegate;
	id<RMTileSource> tileSource;

	NSCountedSet *images;
}

-(id) initWithDelegate: (id) _delegate;

-(void) addTile: (RMTile) tile WithImage: (RMTileImage *)image At: (CGRect) screenLocation;
-(void) addTile: (RMTile) tile At: (CGRect) screenLocation;
// Add tiles inside rect protected to bounds. Return rectangle containing bounds
// extended to full tile loading area
-(CGRect) addTiles: (RMTileRect)rect ToDisplayIn:(CGRect)bounds;

-(RMTileImage*) imageWithTile: (RMTile) tile;
	
-(void) removeTile: (RMTile) tile;
-(void) removeTiles: (RMTileRect)rect;

-(void) removeAllTiles;

-(NSUInteger) count;

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center;

- (void) drawRect:(CGRect) rect;

@property (assign, nonatomic, readwrite) id delegate;
@property (retain, nonatomic, readwrite) id<RMTileSource> tileSource;
@end
