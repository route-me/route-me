//
//  MapTools.h
//  freemap-iphone
//
//  Created by Michel Barakat on 10/20/08.
//  Copyright 2008 Høgskolen i Østfold. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BoundBox.h"
#import "MapCoordinates.h"
#import "MapState.h"
#import "MapTile.h"

@interface MapTools : NSObject {
}

+ (CGPoint)mapTileXYFromMapCoordinates:(MapCoordinates*) mapCoordinates 
								 AtZoom:(int) zoom;

+ (BoundBox*)boundBoxFromMapTile:(MapTile*) mapTile;

+ (CGPoint)tileCenterOffsetFromMapTile:(MapTile*) mapTile;

@end