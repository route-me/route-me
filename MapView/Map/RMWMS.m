//
//  RMWMS.m
//
// Copyright (c) 2008-2011, Route-Me Contributors
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

#import "RMWMS.h"

@implementation RMWMS

@synthesize layers;
@synthesize styles;
@synthesize queryLayers;
@synthesize queryable;
@synthesize crs;
@synthesize infoFormat;
@synthesize format;
@synthesize service;
@synthesize version;
@synthesize exceptions;

- (id) init
{
    self = [super init];
    if (self != nil) {
        // default values
        [self setInfoFormat:@"text/html"];
        [self setCrs:@"EPSG:900913"];
        [self setLayers:@""];
        [self setQueryLayers:@""];
        [self setStyles:@""];
        [self setFormat:@"image/png"];
        [self setService:@"WMS"];
        [self setVersion:@"1.1.1"];
        [self setExceptions:@"application/vnd.ogc.se_inimage"];
    }
    return self;
}

-(void)setUrlPrefix:(NSString *)newUrlPrefix
{
    if (newUrlPrefix) {
        if (!([newUrlPrefix hasSuffix:@"?"]||[newUrlPrefix hasSuffix:@"&"])) {
            if ([newUrlPrefix rangeOfString:@"?"].location == NSNotFound) {
                newUrlPrefix = [newUrlPrefix stringByAppendingString:@"?"];
            } else {
                newUrlPrefix = [newUrlPrefix stringByAppendingString:@"&"];
            }
        }
    }
    
    [urlPrefix release];
    urlPrefix = [newUrlPrefix retain];
}

-(NSString *)urlPrefix
{
    return urlPrefix;
}

-(NSString *)createBaseGet:(NSString *)bbox size:(CGSize)size
{
    return [NSString 
            stringWithFormat:@"%@FORMAT=%@&SERVICE=%@&VERSION=%@&EXCEPTIONS=%@&SRS=%@&BBOX=%@&WIDTH=%.0f&HEIGHT=%.0f&LAYERS=%@&STYLES=%@", 
            urlPrefix, format, service, version, exceptions, crs, bbox, size.width, size.height, layers, styles];
}

-(NSString *)createGetMapForBbox:(NSString *)bbox size:(CGSize)size
{
    return [NSString stringWithFormat:@"%@&REQUEST=GetMap", [self createBaseGet:bbox size:size]];
}

-(NSString *)createGetFeatureInfoForBbox:(NSString *)bbox size:(CGSize)size point:(CGPoint)point
{
    return [NSString 
            stringWithFormat:@"%@&REQUEST=GetFeatureInfo&INFO_FORMAT=%@&X=%.0f&Y=%.0f&QUERY_LAYERS=%@", 
            [self createBaseGet:bbox size:size], infoFormat, point.x, point.y, queryLayers];
}

-(NSString *)createGetCapabilities
{
    return [NSString stringWithFormat:@"%@SERVICE=%@&VERSION=%@&REQUEST=GetCapabilities", urlPrefix, service, version];
}

-(BOOL)isVisible
{
    return ![@"" isEqualToString:layers];
}

// [ layerA, layer B ] -> layerA,layerB
+(NSString *)escapeAndJoin:(NSArray *)elements
{
    NSMutableArray *encoded = [NSMutableArray array];
    for (NSString *element in elements) {
        [encoded addObject:[element stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return [encoded componentsJoinedByString:@","];
}

// layerA,layerB -> [ layerA, layer B ]
+(NSArray *)splitAndDecode:(NSString *)joined
{
    NSMutableArray *split = [NSMutableArray array];
    if ([joined length] == 0) {
        return split;
    }
    for (NSString *element in [joined componentsSeparatedByString:@","]) {
        [split addObject:[element stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return split;
}

-(NSArray *)selectedLayerNames
{
    return [RMWMS splitAndDecode:layers];
}

-(void)setSelectedLayerNames:(NSArray *)layerNames
{
    [self setLayers:[RMWMS escapeAndJoin:layerNames]];
}

-(NSArray *)selectedQueryLayerNames
{
    return [RMWMS splitAndDecode:queryLayers];
}

-(void)setSelectedQueryLayerNames:(NSArray *)layerNames
{
    [self setQueryLayers:[RMWMS escapeAndJoin:layerNames]];
}

-(BOOL)selected:(NSString *)layerName
{
    return [[self selectedLayerNames] containsObject:layerName];
}

-(void)select:(NSString *)layerName queryable:(BOOL)isQueryable
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:[self selectedLayerNames]];
    if (![array containsObject:layerName]) {
        [array addObject:layerName];
        [self setSelectedLayerNames:array];
    }
    
    if (isQueryable) {
        array = [NSMutableArray arrayWithArray:[self selectedQueryLayerNames]];
        if (![array containsObject:layerName]) {
            [array addObject:layerName];
            [self setSelectedQueryLayerNames:array];
        }
    }
}

-(void)deselect:(NSString *)layerName
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:[self selectedLayerNames]];
    [array removeObject:layerName];
    [self setSelectedLayerNames:array];
    
    array = [NSMutableArray arrayWithArray:[self selectedQueryLayerNames]];
    [array removeObject:layerName];
    [self setSelectedQueryLayerNames:array];
}

- (void) dealloc
{
    [self setUrlPrefix:nil];
    [self setLayers:nil];
    [self setStyles:nil];
    [self setQueryLayers:nil];
    [self setCrs:nil];
    [self setInfoFormat:nil];
    [self setFormat:nil];
    [self setService:nil];
    [self setVersion:nil];
    [self setExceptions:nil];
    
    [super dealloc];
}

@end
