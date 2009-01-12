//
//  MapSourceAttributes.m
//  freemap-iphone
//
//  Created by Michel Barakat on 11/7/08.
//  Copyright 2008 Høgskolen i Østfold. All rights reserved.
//

#import "MapSourceAttributes.h"

@implementation MapSourceAttributes

@synthesize minZoom;
@synthesize maxZoom;
@synthesize baseUrl;
@synthesize name;
@synthesize dirName;
@synthesize tileSize;

- (id)initWithMinZoom:(int) initMinZoom MaxZoom:(int) initMaxZoom 
              BaseURL:(NSString*) initBaseUrl Name:(NSString*) initName 
              DirName:(NSString*) initDirName TileSize:(CGSize) initTileSize {
  assert(initBaseUrl != 0);
  assert(initName != 0);
  assert(initDirName != 0);
  
  minZoom = initMinZoom;
  maxZoom = initMaxZoom;
  baseUrl = initBaseUrl;
  name = initName;
  dirName = initDirName;
  tileSize = initTileSize;
  
  return self;
}

- (void)dealloc {
	[baseUrl release];
	[name release];
  [dirName release];
  
	[super dealloc];
}

@end
