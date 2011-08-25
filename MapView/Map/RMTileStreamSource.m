//
//  RMTileStreamSource.h
//
//  Created by Justin R. Miller on 5/17/11.
//  Copyright 2011, Development Seed, Inc.
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
//      * Neither the name of Development Seed, Inc., nor the names of its
//        contributors may be used to endorse or promote products derived from
//        this software without specific prior written permission.
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

#import "RMTileStreamSource.h"

@interface RMTileStreamSource (RMTileStreamSourcePrivate)

@property (nonatomic, retain) NSDictionary *infoDictionary;

@end

#pragma mark -

@implementation RMTileStreamSource

@synthesize infoDictionary;

- (id)initWithInfo:(NSDictionary *)info
{
	if (self = [super init])
        infoDictionary = [[NSDictionary dictionaryWithDictionary:info] retain];
    
	return self;
}

- (id)initWithReferenceURL:(NSURL *)referenceURL
{
    return [self initWithInfo:[NSDictionary dictionaryWithContentsOfURL:referenceURL]];
}

- (void)dealloc
{
    [infoDictionary release];
    
    [super dealloc];
}

#pragma mark 

- (NSString *)tileURL:(RMTile)tile
{
    // flip y value per OSM-style
    //
    NSInteger zoom = tile.zoom;
    NSInteger x    = tile.x;
    NSInteger y    = pow(2, zoom) - tile.y - 1;
    
    NSString *tileURLString = [self.infoDictionary objectForKey:@"tileURL"];
    
    tileURLString = [tileURLString stringByReplacingOccurrencesOfString:@"{z}" withString:[[NSNumber numberWithInteger:zoom] stringValue]];
    tileURLString = [tileURLString stringByReplacingOccurrencesOfString:@"{x}" withString:[[NSNumber numberWithInteger:x]    stringValue]];
    tileURLString = [tileURLString stringByReplacingOccurrencesOfString:@"{y}" withString:[[NSNumber numberWithInteger:y]    stringValue]];
    
	return tileURLString;
}

- (float)minZoom
{
    return [[self.infoDictionary objectForKey:@"minzoom"] floatValue];
}

- (float)maxZoom
{
    return [[self.infoDictionary objectForKey:@"maxzoom"] floatValue];
}

- (RMSphericalTrapezium)latitudeLongitudeBoundingBox
{
    NSArray *parts = [[self.infoDictionary objectForKey:@"bounds"] componentsSeparatedByString:@","];
        
    if ([parts count] == 4)
    {
        RMSphericalTrapezium bounds = {
            .southwest = {
                .longitude = [[parts objectAtIndex:0] doubleValue],
                .latitude  = [[parts objectAtIndex:1] doubleValue],
            },
            .northeast = {
                .longitude = [[parts objectAtIndex:2] doubleValue],
                .latitude  = [[parts objectAtIndex:3] doubleValue],
            },
        };
        
        return bounds;
    }
    
    return kTileStreamDefaultLatLonBoundingBox;
}

- (BOOL)coversFullWorld
{
    RMSphericalTrapezium ownBounds     = [self latitudeLongitudeBoundingBox];
    RMSphericalTrapezium defaultBounds = kTileStreamDefaultLatLonBoundingBox;
    
    if (ownBounds.southwest.longitude <= defaultBounds.southwest.longitude + 10 && 
        ownBounds.northeast.longitude >= defaultBounds.northeast.longitude - 10)
        return YES;
    
    return NO;
}

- (NSString *)uniqueTilecacheKey
{
	return [NSString stringWithFormat:@"%@-%@", [self.infoDictionary objectForKey:@"id"], [self.infoDictionary objectForKey:@"version"]];
}

- (NSString *)shortName
{
	return [self.infoDictionary objectForKey:@"name"];
}

- (NSString *)longDescription
{
	return [self.infoDictionary objectForKey:@"description"];
}

- (NSString *)shortAttribution
{
	return [self.infoDictionary objectForKey:@"attribution"];
}

- (NSString *)longAttribution
{
	return [self shortAttribution];
}

- (RMTileStreamLayerType)layerType
{
    return ([[self.infoDictionary objectForKey:@"type"] isEqualToString:@"overlay"] ? RMTileStreamLayerTypeOverlay : RMTileStreamLayerTypeBaselayer);
}

@end