//
//  RMMarkerStyles.m
//
// Copyright (c) 2008, Route-Me Contributors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

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
