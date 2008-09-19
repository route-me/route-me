//
//  RMMercatorWebSource.h
//  MapView
//
//  Created by Brian Knorr on 9/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMTileSource.h"

@protocol AbstractMecatorWebSource

-(NSString*) tileURL: (RMTile) tile;

@end

@class RMFractalTileProjection;

@interface AbstractMecatorWebSource : NSObject <RMTileSource> {
	RMFractalTileProjection *tileProjection;
}

@end
