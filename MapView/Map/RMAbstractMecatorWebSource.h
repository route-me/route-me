//
//  RMMercatorWebSource.h
//  MapView
//
//  Created by Brian Knorr on 9/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMTileSource.h"

@protocol RMAbstractMecatorWebSource

-(NSString*) tileURL: (RMTile) tile;

@end

@class RMFractalTileProjection;

@interface RMAbstractMecatorWebSource : NSObject <RMTileSource> {
	RMFractalTileProjection *tileProjection;
}

+(int)tileSideLength;

@end
