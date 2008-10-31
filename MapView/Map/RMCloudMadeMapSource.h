//
//  RMCloudMadeMapSource.h
//  MapView
//
//  Created by Dmytro Golub on 10/29/08.
//  Copyright 2008 Cloudmade. Refer to project license.
//

#import "RMAbstractMecatorWebSource.h"


@interface RMCloudMadeMapSource : RMAbstractMecatorWebSource <RMAbstractMecatorWebSource>
{

}

+(int)tileSideLength;

@end
