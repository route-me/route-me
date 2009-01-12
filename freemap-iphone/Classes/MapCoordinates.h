//
//  MapCoordinates.h
//  freemap-iphone
//
//  Created by Michel Barakat on 8/31/08.
//  Copyright 2008 Høgskolen i Østfold. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MapCoordinates : NSObject {

@private
	double latitude;
	double longitude;
}

@property(readwrite,setter=setLatitude:) double latitude; 
@property(readwrite,setter=setLongitude:) double longitude;

- (id)initWithLatitude:(double)initLatitude Longitude:(double)initLongitude;

- (void)setLatitude:(double)newLatitude;
- (void)setLongitude:(double)newLongitude;

@end
