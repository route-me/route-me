//
//  RMCloudMadeMapSource.h
//  MapView
//
// Copyright (c) 2008-2009, Cloudmade
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

#import "RMAbstractMercatorWebSource.h"

/*! 
 \brief Subclass of RMAbstractMercatorWebSource  for access to CloudMade's commercial-grade tile servers.
 
 Provides key-based access to tiles from CloudMade's servers. This is Open Street Map data, but 
 rendered much more nicely, in your choice of stylings. See http://www.cloudmade.com/ for 
 licensing terms and fees. 
 */
@interface RMCloudMadeMapSource : RMAbstractMercatorWebSource <RMAbstractMercatorWebSource>
{
	/// see http://maps.cloudmade.com/ to sample the various CloudMade image styles
	NSUInteger cloudmadeStyleNumber; 
	/// unique key identifying a particular developer/CloudMade licensee. 
	/// See http://developers.cloudmade.com/projects to obtain a CloudMade API key.
	NSString *accessKey;
}

/// designated initializer
- (id) initWithAccessKey:(NSString *)developerAccessKey
			 styleNumber:(NSUInteger)styleNumber;

@end
