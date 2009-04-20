//
//  RMVirtualEarthURL.h
//
// Copyright (c) 2008-2009, Route-Me Contributors
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
 \brief Subclass of RMAbstractMercatorWebSource for access to Microsoft Virtual Earth.
 
 Provides access to USA map tiles from Microsoft Virtual Earth. This implementation is incomplete. It
 requires a SOAP transaction to validate an access key and obtain a session token. Contact Microsoft
 Virtual Earth for further assistance; see contact information in RMVirtualEarthSource.m.

 To obtain a Virtual Earth key, see this blog post:
 http://blogs.msdn.com/virtualearth/archive/2008/04/29/tracking-virtual-earth-tile-usage.aspx

 Microsoft Virtual Earth evangelist: Chris Pendleton, chris.pendleton@microsoft.com
 
 Microsoft Virtual Earth sales: Chris Longo, chris.longo@microsoft.com
 
 This source code sample does not comply with VE terms of service as of March, 2009. To get
 into compliance, you'll have to translate the SOAP call described in the above blog post
 into Objective-C, and modify the URL template in RMVirtualEarthSource.m. If you manage to get
 that working, please contribute your code back to the Route-Me project. When Microsoft was
 invited to submit "blessed" sample code in March, 2009, they declined.
*/
@interface RMVirtualEarthSource : RMAbstractMercatorWebSource <RMAbstractMercatorWebSource> {
	NSString *maptypeFlag;
	NSString *accessKey;
	@private
	NSString *_shortName;
}

- (id) initWithAerialThemeUsingAccessKey:(NSString *)developerAccessKey;
- (id) initWithRoadThemeUsingAccessKey:(NSString *)developerAccessKey;
- (id) initWithHybridThemeUsingAccessKey:(NSString *)developerAccessKey;

-(NSString*) quadKeyForTile: (RMTile) tile;
-(NSString*) urlForQuadKey: (NSString*) quadKey;

@end
