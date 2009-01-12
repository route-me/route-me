//
//  MapLoader.h
//  freemap-iphone
//
//  Created by Michel Barakat on 11/5/08.
//  Copyright 2008 Høgskolen i Østfold. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MapTile.h"

@interface MapLoader : NSObject {
  
}

+ (void)initAll;

+ (void)fetchThread:(id)param;

+ (void)loadImageFromX:(int) x Y:(int) y InTile:(MapTile*) mapTile;

+ (void)pauseFetching;

+ (void)resumeFetching;

+ (void)stopMapTileFetch:(MapTile*) mapTile;

@end
