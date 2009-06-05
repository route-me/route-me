//
//  RMTileMapServiceSource.m
//
// Copyright (c) 2009, Route-Me Contributors
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

#import "RMTileMapServiceSource.h"

@implementation RMTileMapServiceSource

-(id) init: (NSString*) _host uniqueKey: (NSString*) _key minZoom: (float) _minZoom maxZoom: (float) _maxZoom
{
        if (![super init])
                return nil;

        host = _host;
        key = _key;
        minZoom = _minZoom;
        maxZoom = _maxZoom;

        return self;
}


-(NSString*) tileURL: (RMTile) tile
{
	NSString *URL = [NSString stringWithFormat:@"%@/%d/%d/%d.png", host, tile.zoom, tile.x, (uint32_t)pow(2.0,(double)tile.zoom)-1-tile.y];

	return URL;
}

-(float) minZoom
{
        return minZoom;
}
-(float) maxZoom
{
        return maxZoom;
}
-(NSString*) uniqueTilecacheKey
{
        return key;
}
-(NSString *)shortName
{
        return @"TMS";
}
-(NSString *)longDescription
{
        return @"Tile Map Service";
}
-(NSString *)shortAttribution
{
        return @"n/a";
}
-(NSString *)longAttribution
{
        return @"n/a";
}


@end
