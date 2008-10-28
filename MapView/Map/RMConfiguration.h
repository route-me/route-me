//
//  RMConfiguration.h
//  MapView
//
//  Created by Hauke Brandes on 28.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RMConfiguration : NSObject {

	id propList;
	
}

+ (RMConfiguration*) configuration;

- (RMConfiguration*) initWithPath: (NSString*) path;
- (void) dealloc;

- (NSDictionary*) cacheConfiguration;

@end
