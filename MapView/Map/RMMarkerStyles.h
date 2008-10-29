//
//  RMMarkerStyles.h
//  MapView
//
//  Created by Hauke Brandes on 29.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RMMarkerStyles : NSObject {

	NSMutableDictionary* styles;
	
}

+ (RMMarkerStyles*) styles;

- (void) addStyle: (RMMarkerStyle*) style withName: (NSString*) name;
- (RMMarkerStyle*) styleNamed: (NSString*) name;

@end
