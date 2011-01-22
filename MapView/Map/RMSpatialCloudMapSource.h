//
//  RMSpatialCloudMapSource.h
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

#import "RMAbstractMercatorWebSource.h"

/*!
 \brief Subclass of RMAbstractMercatorWebSource for access to SpatialCloud.com MapSources.
 
 Allows access to SpatialCloud.com MapSources. Direct access can be attained using a loginID
 and password. Alternatively, a proxy server can be used in place of a loginID and password. 
 If both a loginID/password pair and a server URL are provided, the server URL will be used.
 
 SpatialCloud.com MapSources are available for purchase & resale for various US & world 
 datasets; in addition, SpatialCloud allows you to host/serve/resell your own datasets. 
 Please visit http://spatialcloud.com to setup your own account, subscribe to the 
 MapSource(s), & create your own MapStream(s), as well as licensing terms and fees.
 */

@interface RMSpatialCloudMapSource : RMAbstractMercatorWebSource <RMAbstractMercatorWebSource> {
	NSString *customServerURL;
	NSString *loginID;
	NSString *password;
}

// URL string of proxy server used to access SpatialCloud.com tiles
//
// If you don't have a proxy server, use the loginID/password combination below
// See http://www.spatialcloud.com/index.cfm?event=home.support for server sample code
// Examples:
// http://127.0.0.1:8080/openbd/custom/server/CFML/index.cfm?
// http://localhost:8080/openbd/SSCustomServer/server/JSP/index.jsp?
// http://localhost/server/PHP/index.php?
@property (nonatomic, retain) NSString *customServerURL;

// LoginID and password used to access a MapStream
//
// See http://www.spatialcloud.com/index.cfm?event=home.support to signup
// For the purposes of this demo, use 20101213051851055 for the loginID and
// gRtXbm79CODFq for the password
// If you don't want to release your loginID in your app's binary, consider
// using a proxy server as mentioned above
@property (nonatomic, retain) NSString *loginID;
@property (nonatomic, retain) NSString *password;

- (id)initWithLoginID:(NSString *)newLoginID password:(NSString *)newPassword;
- (id)initWithCustomServerURL:(NSString *)newCustomServerURL;

@end
