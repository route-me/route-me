//
//  RMCloudMadeMapSource.m
//  MapView
//
// Copyright (c) 2008, Cloudmade
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

#import "RMCloudMadeMapSource.h"


@implementation RMCloudMadeMapSource

#define kDefaultCloudMadeStyleNumber 7

- (id) init
{
	return [self initWithAccessKey:@""
					   styleNumber:kDefaultCloudMadeStyleNumber];
}

/// designated initializer
- (id) initWithAccessKey:(NSString *)developerAccessKey
			 styleNumber:(NSUInteger)styleNumber;
{
	NSAssert((styleNumber > 0), @"CloudMade style number must be positive");
	NSAssert(([developerAccessKey length] > 0), @"CloudMade access key must be non-empty");
	if (self = [super init]) {
		accessKey = developerAccessKey;
		if (styleNumber > 0)
			cloudmadeStyleNumber = styleNumber;
		else
			cloudmadeStyleNumber = kDefaultCloudMadeStyleNumber;
	}
		return self;
}

- (NSString*) tileURL: (RMTile) tile
{
	NSAssert4(((tile.zoom >= self.minZoom) && (tile.zoom <= self.maxZoom)),
			  @"%@ tried to retrieve tile with zoomLevel %d, outside source's defined range %f to %f", 
			  self, tile.zoom, self.minZoom, self.maxZoom);
	return [NSString stringWithFormat:@"http://tile.cloudmade.com/%@/%d/%d/%d/%d/%d.png",
			accessKey,
			cloudmadeStyleNumber,
			[RMCloudMadeMapSource tileSideLength], tile.zoom, tile.x, tile.y];
}

-(NSString*) uniqueTilecacheKey
{
	return [NSString stringWithFormat:@"CloudMadeMaps%d", cloudmadeStyleNumber];
}

+(int)tileSideLength
{
	return 256;
}

@end
