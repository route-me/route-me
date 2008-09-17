//
//  Tile.h
//  Images
//
//  Created by Joseph Gentle on 13/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <CoreGraphics/CoreGraphics.h>
#import <CoreLocation/CoreLocation.h>
#import "Tile.h"

@class TileImage;

extern NSString * const MapImageLoadedNotification;
extern NSString * const MapImageLoadingCancelledNotification;

@interface TileImage : NSObject {
	UIImage *image;

//	CGImageRef image;
	
	// I know this is a bit nasty.
	Tile tile;
	CGRect screenLocation;
	
	int loadingPriorityCount;
	
	NSDate *lastUsedTime;
	
	// Only used when appropriate
	CALayer *layer;
}

- (id) initWithTile: (Tile)tile;

+ (TileImage*) dummyTile: (Tile)tile;

//- (id) increaseLoadingPriority;
//- (id) decreaseLoadingPriority;

+ (TileImage*)imageWithTile: (Tile) tile FromURL: (NSString*)url;
+ (TileImage*)imageWithTile: (Tile) tile FromFile: (NSString*)filename;

- (void)drawInRect:(CGRect)rect;
- (void)draw;

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center;

- (void)makeLayer;

-(void) cancelLoading;

- (void)setImageToData: (NSData*) data;

@property (readwrite, assign) CGRect screenLocation;
@property (readonly, assign) Tile tile;
@property (readonly) CALayer *layer;
@property (readonly) UIImage *image;

@end
