//
//  MapSource.h
//  freemap-iphone
//
//  Created by Michel Barakat on 8/31/08.
//  Copyright 2008 Høgskolen i Østfold. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MapSourceAttributes.h"

// TODO: MapDataSource's should be exactly distributed as in the settings file.
// Find maybe a more elegant solution that would synchronize changes from
// settings file.

enum MapDataSource {
	MAP_DATA_OSM_MAPNIK = 0,
	MAP_DATA_OSM_TILESATHOME,
	MAP_DATA_OSM_CYCLEMAP,
	MAP_DATA_CLOUDMADE_MOBILE_64,
	MAP_DATA_CLOUDMADE_MOBILE_256,
	MAP_DATA_CLOUDMADE_WEB_64,
	MAP_DATA_CLOUDMADE_WEB_256
};
static const int numMapDataSource = 7; // number of options above.

@interface MapSource : NSObject {
	
@private
	enum MapDataSource mapDataSource;
	MapSourceAttributes *mapSourceAttributes;
  UIImage *loadingImage;
  UIImage *failedImage;
}

@property(readonly) enum MapDataSource mapDataSource;
@property(retain) MapSourceAttributes *mapSourceAttributes;
@property(readonly) UIImage *loadingImage;
@property(readonly) UIImage *failedImage;

- (id)initWithMapDataSource:(enum MapDataSource) initSource;

- (int)minZoom;
- (int)maxZoom;
- (NSString*)name;
- (CGSize)tileSize;
- (NSString*)baseUrl;
- (NSString*)dirName;

+ (void)loadMapSources;
+ (const NSMutableArray*)allMapSources;
+ (int)numMapSource;

@end
