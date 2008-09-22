//
//  Mercator.h
//  Images
//
//  Created by Joseph Gentle on 21/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMLatLong.h"

typedef struct {
	double x, y;
} RMMercatorPoint;

typedef struct {
	RMMercatorPoint origin;
	CGSize size;
} RMMercatorRect;

@interface RMMercator : NSObject {

}

+ (CLLocationCoordinate2D) mercatorAsCLLocation: (RMMercatorPoint) merc;
+ (RMMercatorPoint) cLlocationAsMercator: (CLLocationCoordinate2D) coordinate;

+ (CLLocationCoordinate2D) toLatLong: (RMMercatorPoint) coordinate;
+ (RMMercatorPoint) toMercator: (CLLocationCoordinate2D) coordinate;

+ (RMMercatorPoint) clipPoint: (RMMercatorPoint)point ToBounds: (RMMercatorRect) bounds;
//+ (MercatorRect) clipRect: (MercatorRect)rect ToBounds: (MercatorRect) bounds;

@end
