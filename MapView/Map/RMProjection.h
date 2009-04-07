//
//  RMProjection.h
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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "RMFoundation.h"
#import "RMLatLong.h"

/// encapsulates a map projection definition.
@interface RMProjection : NSObject
{
	// This is actually a projPJ, but I don't want to need
	// to include proj_api here.
	void*		internalProjection;
	
	RMXYRect	bounds;
	
	BOOL		projectionWrapsHorizontally;
}

@property (readonly) void* internalProjection;
@property (readonly) RMXYRect bounds;
@property (readwrite) BOOL projectionWrapsHorizontally;

/// Assuming the earth is round, this will wrap a point around the bounds. 
- (RMXYPoint) wrapPointHorizontally: (RMXYPoint) aPoint;

/// This method wraps the x and clamps the y.
- (RMXYPoint) constrainPointToBounds: (RMXYPoint) aPoint;

+ (RMProjection *) googleProjection;
+ (RMProjection *) EPSGLatLong;
+ (RMProjection *) OSGB;

- (id) initWithString: (NSString*)params InBounds: (RMXYRect) projBounds;

/// inverse project meters, return latitude/longitude
/// \deprecated rename pending after 0.5
- (RMLatLong)pointToLatLong:(RMXYPoint)aPoint;
/// forward project latitude/longitude, return meters
/// \deprecated rename pending after 0.5
- (RMXYPoint)latLongToPoint:(RMLatLong)aLatLong;

@end
