//
//  RMMarkerStyles.m
//  MapView
//
//  Created by Hauke Brandes on 29.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMMarker.h"
#import "RMMarkerStyle.h"

#import "RMMarkerStyles.h"


@implementation RMMarkerStyles


static RMMarkerStyles *sharedMarkerStyles = nil;

+ (RMMarkerStyles*)styles
{
    @synchronized(self) {
        if (sharedMarkerStyles == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedMarkerStyles;
}

- (RMMarkerStyles*) init 
{
	self = [super init];
	if (self==nil) return nil;
	
	styles = [[NSMutableDictionary dictionaryWithObjectsAndKeys: 
			  [RMMarkerStyle markerStyleWithIcon: [UIImage imageWithCGImage: [RMMarker markerImage: RMMarkerBlueKey]]], RMMarkerBlueKey,
			  [RMMarkerStyle markerStyleWithIcon: [UIImage imageWithCGImage: [RMMarker markerImage: RMMarkerRedKey]]], RMMarkerRedKey,
			  nil
	] retain];
	
	return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedMarkerStyles == nil) {
            sharedMarkerStyles = [super allocWithZone:zone];
            return sharedMarkerStyles;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

- (void)dealloc
{
	[styles release];
	[super dealloc];
}

- (void) addStyle: (RMMarkerStyle*) style withName: (NSString*) name
{
	[styles setObject:style	forKey:name];
}

- (RMMarkerStyle*) styleNamed: (NSString*) name
{
	return [styles objectForKey:name];
}


@end
