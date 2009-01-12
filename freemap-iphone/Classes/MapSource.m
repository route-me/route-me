//
//  MapSource.m
//  freemap-iphone
//
//  Created by Michel Barakat on 8/31/08.
//  Copyright 2008 Høgskolen i Østfold. All rights reserved.
//

#import <sys/stat.h>

#import "MapSource.h"
#import "MapLoader.h"

#define CLOUDMADE_API_KEY "f799927d0b8b57b291dd8d84a53e611c"

@implementation MapSource

@synthesize mapDataSource;
@synthesize mapSourceAttributes;
@synthesize loadingImage;
@synthesize failedImage;

static NSMutableArray* allMapDataSources = 0;

+ (void)loadMapSources {
  assert(allMapDataSources == 0);

  allMapDataSources =
    [[NSMutableArray alloc] initWithCapacity:numMapDataSource];
  for (int i = 0; i < numMapDataSource; ++i) {
    MapSourceAttributes *attributes = [MapSourceAttributes alloc];
    switch(i) {
      case MAP_DATA_OSM_MAPNIK:
        attributes = [attributes 
                      initWithMinZoom:0 
                      MaxZoom:18 
                      BaseURL:@"http://tile.openstreetmap.org/" 
                      Name:@"Mapnik" 
                      DirName:@"mapnik" 
                      TileSize:CGSizeMake(256.0, 256.0)];
      break;
        
      case MAP_DATA_OSM_TILESATHOME:
        attributes = [attributes 
                      initWithMinZoom:0 
                      MaxZoom:17 
                      BaseURL:@"http://tah.openstreetmap.org/Tiles/tile/" 
                      Name:@"Tiles @ Home" 
                      DirName:@"tah" 
                      TileSize:CGSizeMake(256.0, 256.0)];
      break;
        
      case MAP_DATA_OSM_CYCLEMAP:
        attributes = [attributes 
                    initWithMinZoom:0 
                    MaxZoom:18 
                    BaseURL:@"http://a.andy.sandbox.cloudmade.com/tiles/cycle/" 
                    Name:@"Cycle Map" 
                    DirName:@"cyclemap" 
                    TileSize:CGSizeMake(256.0, 256.0)];
      break;
        
      case MAP_DATA_CLOUDMADE_MOBILE_64:
        attributes = [attributes 
                      initWithMinZoom:0 
                      MaxZoom:18 
                      BaseURL:[[NSString alloc] initWithFormat:
                               @"http://tiles.cloudmade.com/%s/2/64/", 
                               CLOUDMADE_API_KEY]
                      Name:@"CloudMade Mobile 64" 
                      DirName:@"cmm64" 
                      TileSize:CGSizeMake(64.0, 64.0)];
      break;
        
      case MAP_DATA_CLOUDMADE_MOBILE_256:
        attributes = [attributes 
                      initWithMinZoom:0 
                      MaxZoom:18 
                      BaseURL:[[NSString alloc] initWithFormat:
                               @"http://tiles.cloudmade.com/%s/2/256/", 
                               CLOUDMADE_API_KEY]
                      Name:@"CloudMade Mobile 256" 
                      DirName:@"cmm256" 
                      TileSize:CGSizeMake(256.0, 256.0)];
      break;
        
      case MAP_DATA_CLOUDMADE_WEB_64:
        attributes = [attributes 
                      initWithMinZoom:0 
                      MaxZoom:18 
                      BaseURL:[[NSString alloc] initWithFormat:
                               @"http://tiles.cloudmade.com/%s/1/64/", 
                               CLOUDMADE_API_KEY]
                      Name:@"CloudMade Web 64" 
                      DirName:@"cwm64" 
                      TileSize:CGSizeMake(64.0, 64.0)];
      break;
        
      case MAP_DATA_CLOUDMADE_WEB_256:
        attributes = [attributes 
                      initWithMinZoom:0 
                      MaxZoom:18 
                      BaseURL:[[NSString alloc] initWithFormat:
                               @"http://tiles.cloudmade.com/%s/1/256/", 
                               CLOUDMADE_API_KEY]
                      Name:@"CloudMade Web 256" 
                      DirName:@"cwm256" 
                      TileSize:CGSizeMake(256.0, 256.0)];
      break;
    }
    
    [allMapDataSources insertObject:attributes atIndex:i];
  }
  
  assert([allMapDataSources count] == numMapDataSource);
}

- (id)initWithMapDataSource:(enum MapDataSource) initSource {
  if (allMapDataSources == 0) {
    [MapSource loadMapSources];
  }
  
	mapDataSource = initSource;
  mapSourceAttributes = [allMapDataSources objectAtIndex:mapDataSource];
	
  if ([mapSourceAttributes tileSize].height == 64 && 
      [mapSourceAttributes tileSize].width == 64) {
    loadingImage = [UIImage imageNamed:@"loading64.png"];
    failedImage = [UIImage imageNamed:@"failed64.png"];
  } else if ([mapSourceAttributes tileSize].height == 256 &&
             [mapSourceAttributes tileSize].width == 256) {
    loadingImage = [UIImage imageNamed:@"loading256.png"];
    failedImage = [UIImage imageNamed:@"failed256.png"];
  }
  
  NSString *writeDir = [NSString stringWithFormat:@"%@/Documents/", 
                        NSHomeDirectory()];
  if (mkdir([writeDir cStringUsingEncoding:NSASCIIStringEncoding], 0755) == 0) {
    NSLog(@"Map directory missing, created %@", writeDir);
  }
  
  [MapLoader initAll];
  
  return self;
}

- (int)minZoom {
  return [mapSourceAttributes minZoom]; 
}

- (int)maxZoom {
  return [mapSourceAttributes maxZoom];
}

- (NSString*)name {
  return [mapSourceAttributes name];
}

- (CGSize)tileSize {
  return [mapSourceAttributes tileSize];
}

- (NSString*)baseUrl {
  return [mapSourceAttributes baseUrl];
}

- (NSString*)dirName {
  return [mapSourceAttributes dirName];
}

+ (const NSMutableArray*)allMapSources {
  assert(allMapDataSources != 0);
  
  return allMapDataSources;
}

+ (int)numMapSource {
  return numMapDataSource;
}

- (void)dealloc {
	[super dealloc];
}

@end
