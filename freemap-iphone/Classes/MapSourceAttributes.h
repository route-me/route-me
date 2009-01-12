//
//  MapSourceAttributes.h
//  freemap-iphone
//
//  Created by Michel Barakat on 11/7/08.
//  Copyright 2008 Høgskolen i Østfold. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MapSourceAttributes : NSObject {
  
@private
  int minZoom;
  int maxZoom;
  NSString* baseUrl;
  NSString* name;
  NSString* dirName;
  CGSize tileSize;
}

@property(readonly) int minZoom;
@property(readonly) int maxZoom;
@property(readonly) NSString* baseUrl;
@property(readonly) NSString* name;
@property(readonly) NSString* dirName;
@property(readonly) CGSize tileSize;

- (id)initWithMinZoom:(int) initMinZoom MaxZoom:(int) initMaxZoom 
              BaseURL:(NSString*) initBaseUrl Name:(NSString*) initName 
              DirName:(NSString*) initDirName TileSize:(CGSize) initTileSize;

@end
