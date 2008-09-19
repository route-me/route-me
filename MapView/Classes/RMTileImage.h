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
#import "RMTile.h"

@class RMTileImage;

extern NSString * const RMMapImageLoadedNotification;
extern NSString * const RMMapImageLoadingCancelledNotification;

@interface RMTileImage : NSObject {
	UIImage *image;

//	CGImageRef image;
	
	// I know this is a bit nasty.
	RMTile tile;
	CGRect screenLocation;
	
	int loadingPriorityCount;
	
	// Used by cache
	NSDate *lastUsedTime;
	
	// Only used when appropriate
	CALayer *layer;
}

- (id) initWithTile: (RMTile)tile;

+ (RMTileImage*) dummyTile: (RMTile)tile;

//- (id) increaseLoadingPriority;
//- (id) decreaseLoadingPriority;

+ (RMTileImage*)imageWithTile: (RMTile) tile FromURL: (NSString*)url;
+ (RMTileImage*)imageWithTile: (RMTile) tile FromFile: (NSString*)filename;

- (void)drawInRect:(CGRect)rect;
- (void)draw;

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center;

- (void)makeLayer;

-(void) cancelLoading;

- (void)setImageToData: (NSData*) data;

-(void) touch;

@property (readwrite, assign) CGRect screenLocation;
@property (readonly, assign) RMTile tile;
@property (readonly) CALayer *layer;
@property (readonly) UIImage *image;
@property (readonly) NSDate *lastUsedTime;

@end
