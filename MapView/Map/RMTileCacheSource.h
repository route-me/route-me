//
//  RMTileCacheSource.h
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

#import "RMAbstractMercatorWebSource.h"

/*! 
 brief Subclass of RMAbstractMercatorWebSource for access to a fully-seeded TileCache source.
 
 TileCache directory zoom levels do not necessarily correspond to the internal zoom levels of
 route-me.  That is, route-me's default zoom level of 0 is comprised of 4 tiles (2x2), while
 a TileCache source could be constructed of some other power of 2, such as 64 tiles (8x8).  
 When itializing a TileCache source with initWithTSURL:zoomAdj:fileType, zoomAdj must be equal 
 to the power of 2 that corresponds to the number of tiles on one axis your TileCache directory.
 Therefore, given the previous example of 64 tiles from 8 tiles on each axis, zoomAdj = 3, 
 as 2^3 = 8.
*/

@interface RMTileCacheSource : RMAbstractMercatorWebSource <RMAbstractMercatorWebSource> {
	@private
	NSString *_shortName;
	NSString *urlSource;
	NSInteger zoomAdjustment;
	NSString *fileType;
}

- (id) initWithTSUrl:(NSString*)tileCacheUrl zoomAdj:(NSInteger)adj fileType:(NSString*)type;

-(NSString*) urlForTile: (RMTile)tile;
-(NSString*) zeropad: (NSInteger)number :(NSInteger)length;

@end
