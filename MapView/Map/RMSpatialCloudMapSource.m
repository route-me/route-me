//
//  RMSpatialCloudMapSource.m
//
// Copyright (c) 2011, SpatialCloud
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

#import "RMSpatialCloudMapSource.h"
#import <CommonCrypto/CommonDigest.h>


@implementation RMSpatialCloudMapSource

@synthesize customServerURL;
@synthesize loginID;
@synthesize password;

- (id)init {
	self = [super init];
	if (self) {
		[self setMaxZoom:18];
		[self setMinZoom:1];
	}
	return self;
}

- (id)initWithLoginID:(NSString *)newLoginID password:(NSString *)newPassword {
	self = [self init];
	if (self) {
		loginID = [newLoginID retain];
		password = [newPassword retain];
	}
	return self;
}

- (id)initWithCustomServerURL:(NSString *)newCustomServerURL {
	self = [self init];
	if (self) {
		customServerURL = [newCustomServerURL retain];
	}
	return self;
}

- (void)dealloc {
	[customServerURL release];
	[loginID release];
	[password release];
	[super dealloc];
}

- (NSString *)md5HexDigest:(NSString *)stringToHash {
	const char *cStringToHash = [stringToHash UTF8String];
	unsigned char hash[CC_MD5_DIGEST_LENGTH];
	CC_MD5(cStringToHash, strlen(cStringToHash), hash);
	
	NSMutableString *hashString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [hashString appendFormat:@"%02X", hash[i]];
    }
	return hashString;
}

- (NSString *)tileURL:(RMTile)tile {
	NSAssert4(((tile.zoom >= self.minZoom) && (tile.zoom <= self.maxZoom)),
			  @"%@ tried to retrieve tile with zoomLevel %d, outside source's defined range %f to %f", 
			  self, tile.zoom, self.minZoom, self.maxZoom);
	NSAssert(([self.loginID length] > 0) || ([self.customServerURL length] > 0),
			 @"Login ID or Custom Server URL for Spatial Cloud must be non-empty");
	NSAssert(([self.password length] > 0) || ([self.customServerURL length] > 0),
			 @"Password or Custom Server URL for Spatial Cloud must be non-empty");
	
	// Flip the y-coordinate from the default route-me scheme to the Spatial Cloud tile scheme
	uint32_t flippedYCoordinate = (1 << tile.zoom) - 1 - tile.y;
	
	NSString* fullURL = nil;
	if ([self.customServerURL length] > 0) {
		fullURL = [NSString stringWithFormat:@"%@%d/%d/%d.jpg",
				   customServerURL, tile.zoom, tile.x, flippedYCoordinate];
	} else {
		NSString *serverURL = @"http://ss.spatialcloud.com/getsign.cfm";
		NSString *fileKey = [NSString stringWithFormat:@"%d/%d/%d.jpg",
							 tile.zoom, tile.x, flippedYCoordinate];
		
		NSString *authSign = [NSString stringWithFormat:@"%@%@%@",
							  fileKey, self.loginID, self.password];
		NSString *authSignHash = [self md5HexDigest:authSign];
		
		fullURL = [NSString stringWithFormat:@"%@/1.0.0/spatialcloud/%@?loginid=%@&authSign=%@&viewer=viewer",
				   serverURL, fileKey, self.loginID, authSignHash];
	}
	
	return fullURL;
}

- (NSString *)uniqueTilecacheKey {
	return @"SpatialCloud";
}

- (NSString *)shortName {
	return @"SpatialCloud.com";
}

- (NSString *)longDescription {
	return @"SpatialCloud.com MapSources are available for purchase & resale for various US & world datasets; in addition, SpatialCloud allows you to host/serve/resell your own datasets. Learn more at SpatialCloud.com.";
}

- (NSString *)shortAttribution {
	return @"Spatial Cloud Demo";
}

- (NSString *)longAttribution {
	return @"SpatialCloud MapSource terms vary, but this SpatialCloud Demo is for Route-Me code demo purposes only.  The demo MapSource provided is SpatialCloud USA, which is typically licensed using the flexible Creative Commons Attribution 3.0 Unported terms when subscribed to. If implementing this Route-Me code in your application, please visit SpatialCloud.com and setup your own account, subscribe to the MapSource(s), & create your own MapStream(s). If the demo is abused SpatialCloud may be forced to disable this demo for all.";
}

@end
