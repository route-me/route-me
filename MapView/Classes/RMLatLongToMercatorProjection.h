//
//  Mercator.h
//  Images
//
//  Created by Joseph Gentle on 21/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMLatLong.h"
#import <CoreGraphics/CGGeometry.h>
#import "RMMercator.h"

@class RMProjection;

@interface RMLatLongToMercatorProjection : NSObject
{
	RMProjection *projection;
}

-(id) initWithProjection: (RMProjection*) projection;

// Convert Mercator <-> Lat/long
-(CLLocationCoordinate2D) projectMercatorToLatLong: (RMMercatorPoint) coordinate;
-(RMMercatorPoint) projectLatLongToMercator: (CLLocationCoordinate2D) coordinate;


// Rewrite coordinates without transforming them. You probably want the transformation functions above.
+(CLLocationCoordinate2D) mercatorAsCLLocation:(RMMercatorPoint) merc;
+(RMMercatorPoint) cLlocationAsMercator:(CLLocationCoordinate2D) coordinate;

+(RMLatLongToMercatorProjection*) googleProjection;

@end

//+ (RMMercatorPoint) clipPoint: (RMMercatorPoint)point ToBounds: (RMMercatorRect) bounds;
//+ (MercatorRect) clipRect: (MercatorRect)rect ToBounds: (MercatorRect) bounds;


