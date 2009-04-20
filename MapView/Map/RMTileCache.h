//
//  RMTileCache.h
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
#import "RMTileSource.h"

@class RMTileImage;

typedef enum {
	RMCachePurgeStrategyLRU,
	RMCachePurgeStrategyFIFO,
} RMCachePurgeStrategy;


@protocol RMTileCache<NSObject>

/// Returns the cached image if it exists. nil otherwise.
-(RMTileImage*) cachedImage:(RMTile)tile;
-(void)didReceiveMemoryWarning;

@optional

-(void)addTile: (RMTile)tile WithImage: (RMTileImage*)image;
/// removes all tile images from the memory and disk subcaches
-(void)removeAllCachedImages;

@end


@interface RMTileCache : NSObject<RMTileCache>
{
	NSMutableArray *caches;
}

-(id)initWithTileSource: (id<RMTileSource>) tileSource;

+(NSNumber*) tileHash: (RMTile)tile;

/// Add tile to cache
/*! 
 \bug Calls -makeSpaceInCache for every tile/image addition. -makeSpaceInCache does a linear scan of its contents at each call.

 \bug Since RMTileImage has an RMTile ivar, this API should be simplified to just -addImage:.
 */
-(void)addTile: (RMTile)tile WithImage: (RMTileImage*)image;

/// Add another cache to the chain
-(void)addCache: (id<RMTileCache>)cache;

-(void)didReceiveMemoryWarning;

@end
