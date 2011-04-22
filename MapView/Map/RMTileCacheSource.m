//
//  RMTileCacheSource.m
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

#import "RMTileCacheSource.h"

@implementation RMTileCacheSource
- (id) init
{
	return [self initWithTSUrl:@"" zoomAdj:0 fileType:@""];
}

- (id) initWithTSUrl:(NSString*)tileCacheUrl zoomAdj:(NSInteger)adj fileType:(NSString*)type
{
	if (self = [super init]) 
	{
		zoomAdjustment = adj;
		
		_shortName = [NSString stringWithString:@"TileCache Source"];
		urlSource = [NSString stringWithString:tileCacheUrl];
		fileType = [NSString stringWithString:type];
	}
	return self;
};

-(NSString*) tileURL: (RMTile) tile
{
	return [self urlForTile:tile];
}

-(NSString*) zeropad: (NSInteger)number :(NSInteger)length
{
	NSString *result;
	NSString *numString = [NSString stringWithFormat:@"%d", number];
	result = [NSString stringWithFormat:@"%@%@", [@"000" substringToIndex:length-[numString length]], numString];
	return result;
}

-(NSString*) urlForTile: (RMTile) tile
{
	NSInteger yReversal = pow(2.0, tile.zoom) - 1;
	
	return [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",
			urlSource,
			@"/",
			[self zeropad:(tile.zoom-zoomAdjustment):2], 
			@"/",
			[self zeropad:((tile.x)/1000000):3], 
			@"/",
			[self zeropad:(((tile.x)/1000)%1000):3], 
			@"/",
			[self zeropad:((tile.x)%1000):3], 
			@"/",
			[self zeropad:((yReversal - tile.y)/1000000):3], 
			@"/",
			[self zeropad:(((yReversal - tile.y)/1000)%1000):3], 
			@"/",
			[self zeropad:((yReversal - tile.y)%1000):3], 
			@".png"];
}

-(NSString*) uniqueTilecacheKey
{
	return @"TileCache Source";
}

-(NSString *)shortName
{
	return _shortName;
}
-(NSString *)longDescription
{
	return [NSString stringWithFormat:@"TileCache Source: %@",urlSource];
}
-(NSString *)shortAttribution
{
	return @"TileCache Source";
}
-(NSString *)longAttribution
{
	return @"TileCache Source";
}

@end
