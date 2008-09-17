//
//  Mercator.h
//  Images
//
//  Created by Joseph Gentle on 21/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
//#import <Foundation/Foundation.h>

typedef struct {
	double x, y;
} MercatorPoint;

typedef struct {
	MercatorPoint origin;
	CGSize size;
} MercatorRect;

@interface Mercator : NSObject {

}

+ (CLLocationCoordinate2D) mercatorAsCLLocation: (MercatorPoint) merc;
+ (MercatorPoint) cLlocationAsMercator: (CLLocationCoordinate2D) coordinate;

+ (CLLocationCoordinate2D) toLatLong: (MercatorPoint) coordinate;
+ (MercatorPoint) toMercator: (CLLocationCoordinate2D) coordinate;

+ (MercatorPoint) clipPoint: (MercatorPoint)point ToBounds: (MercatorRect) bounds;
//+ (MercatorRect) clipRect: (MercatorRect)rect ToBounds: (MercatorRect) bounds;

@end
