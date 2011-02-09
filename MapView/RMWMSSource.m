//
//  RMWMSSource.m
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

#import "RMWMSSource.h"


@implementation RMWMSSource

@synthesize minZoom;
@synthesize maxZoom;
@synthesize name;
@synthesize uniqueTilecacheKey;
@synthesize wms;

-(id) init 
{ 
    if (![super init]) 
        return nil; 
    
    // The code below is based on the followin URL, but fixed for this use
    // http://groups.google.com/group/route-me-map/browse_thread/thread/b6aa3757d46055aa/c93e7b0c861973e5?lnk=gst&q=900913#c93e7b0c861973e5
    
    initialResolution = 2 * M_PI * 6378137 / kDefaultTileSize; 
    originShift = 2 * M_PI * 6378137 / 2.0; 
    
    [self setMinZoom:1.0];
    [self setMaxZoom:18.0];

    // some default values
    [self setName:@"wms"];
    [self setUniqueTilecacheKey:@"wms"];
    
    return self; 
} 

-(NSString*) bboxForTile: (RMTile) tile
{
    float resolution = [self resolutionAtZoom: tile.zoom];
    CGPoint min = [self pixelsToMetersAtZoom: (tile.x     * kDefaultTileSize) PixelY:((tile.y+1) * kDefaultTileSize) atResolution:resolution];
    CGPoint max = [self pixelsToMetersAtZoom: ((tile.x+1) * kDefaultTileSize) PixelY:((tile.y)   * kDefaultTileSize) atResolution:resolution];
    return [NSString stringWithFormat:@"%f,%f,%f,%f", 
            min.x, min.y, max.x, max.y];
}

-(NSString*) tileURL: (RMTile) tile
{
    NSString *bbox = [self bboxForTile:tile];
    return [wms createGetMapForBbox:bbox size:CGSizeMake(kDefaultTileSize, kDefaultTileSize)];
}

//Resolution (meters/pixel) for given zoom level (measured at Equator) 
-(float) resolutionAtZoom : (int) zoom 
{ 
    return initialResolution /pow (2,zoom); 
} 

// Converts pixel coordinates in given resolution to EPSG: 900913 
-(CGPoint) pixelsToMetersAtZoom: (int) px PixelY:(int)py atResolution:(float) resolution 
{ 
    CGPoint meters; 
    meters.x = (px * resolution) - originShift; 
    meters.y = originShift - (py * resolution); 
    return meters; 
} 

- (void) dealloc
{
    [self setName:nil];
    [self setUniqueTilecacheKey:nil];
    [self setWms:nil];
    
    [super dealloc];
}

@end
