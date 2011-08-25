//
//  RMMBTilesTileSource.h
//
//  Created by Justin R. Miller on 6/18/10.
//  Copyright 2010, Code Sorcery Workshop, LLC and Development Seed, Inc.
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//  
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//      * Neither the names of Code Sorcery Workshop, LLC or Development Seed,
//        Inc., nor the names of its contributors may be used to endorse or
//        promote products derived from this software without specific prior
//        written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  http://mbtiles.org
//
//  Example usage at https://github.com/mapbox/mbtiles-ios-example
//

#import <Foundation/Foundation.h>
#import "RMTileSource.h"

@class RMFractalTileProjection;
@class FMDatabase;

#define kMBTilesDefaultTileSize 256
#define kMBTilesDefaultMinTileZoom 0
#define kMBTilesDefaultMaxTileZoom 22
#define kMBTilesDefaultLatLonBoundingBox ((RMSphericalTrapezium){ .northeast = { .latitude =  85, .longitude =  180 }, \
                                                                  .southwest = { .latitude = -85, .longitude = -180 } })

typedef enum {
    RMMBTilesLayerTypeBaselayer = 0,
    RMMBTilesLayerTypeOverlay   = 1,
} RMMBTilesLayerType;

@interface RMMBTilesTileSource : NSObject <RMTileSource>
{
    RMFractalTileProjection *tileProjection;
    FMDatabase *db;
}

- (id)initWithTileSetURL:(NSURL *)tileSetURL;
- (int)tileSideLength;
- (void)setTileSideLength:(NSUInteger)aTileSideLength;
- (RMTileImage *)tileImage:(RMTile)tile;
- (NSString *)tileURL:(RMTile)tile;
- (NSString *)tileFile:(RMTile)tile;
- (NSString *)tilePath;
- (id <RMMercatorToTileProjection>)mercatorToTileProjection;
- (RMProjection *)projection;
- (float)minZoom;
- (float)maxZoom;
- (void)setMinZoom:(NSUInteger)aMinZoom;
- (void)setMaxZoom:(NSUInteger)aMaxZoom;
- (RMSphericalTrapezium)latitudeLongitudeBoundingBox;
- (BOOL)coversFullWorld;
- (RMMBTilesLayerType)layerType;
- (void)didReceiveMemoryWarning;
- (NSString *)uniqueTilecacheKey;
- (NSString *)shortName;
- (NSString *)longDescription;
- (NSString *)shortAttribution;
- (NSString *)longAttribution;
- (void)removeAllCachedImages;

@end