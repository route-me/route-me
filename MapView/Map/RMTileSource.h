//
//  RMTileSource.h
//
// Copyright (c) 2008-2009, Route-Me Contributors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#import <Foundation/Foundation.h>
#import "RMTile.h"
#import "RMLatLong.h"
#import "RMFoundation.h"

@class RMTileImage;
@class RMFractalTileProjection;
@class RMTileLoader;
@class RMTiledLayerController;
@class RMTileCache;
@protocol RMMercatorToTileProjection;
@class RMProjection;

@protocol RMTileSource <NSObject>

-(RMTileImage *) tileImage: (RMTile) tile;
-(NSString *) tileURL: (RMTile) tile;
-(NSString *) tileFile: (RMTile) tile;
-(NSString *) tilePath;
-(id<RMMercatorToTileProjection>) mercatorToTileProjection;
-(RMProjection*) projection;

-(float) minZoom;
-(float) maxZoom;

-(void) setMinZoom:(NSUInteger) aMinZoom;
-(void) setMaxZoom:(NSUInteger) aMaxZoom;

-(RMSphericalTrapezium) latitudeLongitudeBoundingBox;

-(void) didReceiveMemoryWarning;

-(NSString *)uniqueTilecacheKey;

-(NSString *)shortName;
-(NSString *)longDescription;
-(NSString *)shortAttribution;
-(NSString *)longAttribution;

/*! \brief clear all images from the in-memory and on-disk image caches
 \bug This method belongs on RMCachedTileSource, not on RMTileSource, because an RMTileSource doesn't have a cache.
 */
-(void)removeAllCachedImages;

@end
