//
//  NSUserDefaults+RouteMe.m
// 
// Copyright (c) 2008-2011, Route-Me Contributors
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
//

#import "NSUserDefaults+RouteMe.h"

#define kEasting @"easting"
#define kNorthing @"northing"
#define kWidth @"width"
#define kHeight @"height"

@implementation NSUserDefaults (RouteMe)

- (RMProjectedPoint)projectedPointForKey:(NSString *)key {
	NSDictionary *projectedPointDictionary = [self dictionaryForKey:key];
	RMProjectedPoint projectedPoint = RMMakeProjectedPoint([[projectedPointDictionary objectForKey:kEasting] doubleValue],
														   [[projectedPointDictionary objectForKey:kNorthing] doubleValue]);
	return projectedPoint;
}

- (void)setProjectedPoint:(RMProjectedPoint)projectedPoint forKey:(NSString *)key {
	NSDictionary *projectedPointDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
											  [NSNumber numberWithDouble:projectedPoint.easting], kEasting,
											  [NSNumber numberWithDouble:projectedPoint.northing], kNorthing, nil];
	[self setObject:projectedPointDictionary forKey:key];
}

- (RMProjectedRect)projectedRectForKey:(NSString *)key {
	NSDictionary *projectedRectDictionary = [self dictionaryForKey:key];
	RMProjectedRect projectedRect = RMMakeProjectedRect([[projectedRectDictionary objectForKey:kEasting] doubleValue],
														[[projectedRectDictionary objectForKey:kNorthing] doubleValue],
														[[projectedRectDictionary objectForKey:kWidth] doubleValue],
														[[projectedRectDictionary objectForKey:kHeight] doubleValue]);
	return projectedRect;
}

- (void)setProjectedRect:(RMProjectedRect)projectedRect forKey:(NSString *)key {
	NSDictionary *projectedRectDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
											 [NSNumber numberWithDouble:projectedRect.origin.easting], kEasting,
											 [NSNumber numberWithDouble:projectedRect.origin.northing], kNorthing,
											 [NSNumber numberWithDouble:projectedRect.size.width], kWidth,
											 [NSNumber numberWithDouble:projectedRect.size.height], kHeight, nil];
	[self setObject:projectedRectDictionary forKey:key];
}

@end
