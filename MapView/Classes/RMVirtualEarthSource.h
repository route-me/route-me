//
//  RMVirtualEarthURL.h
//  MapView
//
//  Created by Brian Knorr on 9/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AbstractMecatorWebSource.h"

@interface RMVirtualEarthSource : AbstractMecatorWebSource <AbstractMecatorWebSource> {
}

-(NSString*) quadKeyForTile: (RMTile) tile;
-(NSString*) urlForQuadKey: (NSString*) quadKey;

@end
