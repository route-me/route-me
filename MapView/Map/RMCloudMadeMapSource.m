//
//  RMCloudMadeMapSource.m
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

#import "RMCloudMadeMapSource.h"

@implementation RMCloudMadeMapSource

#define kDefaultCloudMadeStyleNumber 7
#define kDefaultCloudMadeSize 256
#define kTokenFileName @"accessToken"
NSString * const RMCloudMadeAccessTokenRequestFailed = @"RMCloudMadeAccessTokenRequestFailed"; 
#define CMTokenAuthorizationServer  @"http://auth.cloudmade.com" 


+ (NSString*)pathForSavedAccessToken
{
	NSArray *paths;
	paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0) // Should only be one...
	{
		NSString *cachePath = [paths objectAtIndex:0];
		return [cachePath stringByAppendingPathComponent:kTokenFileName];
	}
	return nil;
}

-(BOOL) readTokenFromFile
{
	NSString* pathToSavedAccessToken = [RMCloudMadeMapSource pathForSavedAccessToken];
	if([[NSFileManager defaultManager] fileExistsAtPath:pathToSavedAccessToken])
	{
		NSError* error;
		accessToken = [[NSString alloc] initWithContentsOfFile:pathToSavedAccessToken encoding:NSASCIIStringEncoding error:&error];
		if(!accessToken)
		{
			RMLog(@"can't read file %@ %@\n",pathToSavedAccessToken,error.localizedDescription);
			[[NSFileManager defaultManager] removeItemAtPath:pathToSavedAccessToken error:nil];
			return FALSE;
		}
		return TRUE;
	}
	return FALSE;
}

-(void) requestToken
{
	
	if([self readTokenFromFile])
			return;
	
	NSString* url = [NSString stringWithFormat:@"%@/token/%@?userid=%u",CMTokenAuthorizationServer,accessKey,
					[[UIDevice currentDevice].uniqueIdentifier hash]];

	
	NSData* data = nil;
	RMLog(@"%s, url = %@\n",__FUNCTION__,url);
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:5.0];
	[ theRequest setHTTPMethod: @"POST" ];

	NSURLResponse* response;
	NSError*       error = nil; 
	BOOL done = FALSE;
	int attempt = 0;
	do
	{
		data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
		if(data && [(NSHTTPURLResponse*)response statusCode] == 200)
		{
			NSString* pathToSavedAccessToken = [RMCloudMadeMapSource pathForSavedAccessToken];
			accessToken = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
			[accessToken writeToFile:pathToSavedAccessToken atomically:YES encoding:NSASCIIStringEncoding error:nil];
			done = TRUE;
		}
		else
		{
			if([(NSHTTPURLResponse*)response statusCode] == 403 && !attempt)
			{
				RMLog(@"Token wasn't obtained.Response code = %d\n",[(NSHTTPURLResponse*)response statusCode]);
				attempt++;
			}
			else
			{
				RMLog(@"Token wasn't obtained %@\n",error.localizedDescription);
				[[NSNotificationCenter defaultCenter] postNotificationName:RMCloudMadeAccessTokenRequestFailed object:error];
				done = TRUE;
			}
			
		}
	}
	while(!done);
}

- (id) init
{
	return [self initWithAccessKey:@""
					   styleNumber:kDefaultCloudMadeStyleNumber];
}

/// designated initializer
- (id) initWithAccessKey:(NSString *)developerAccessKey
			 styleNumber:(NSUInteger)styleNumber;
{
	NSAssert((styleNumber > 0), @"CloudMade style number must be positive");
	NSAssert(([developerAccessKey length] > 0), @"CloudMade access key must be non-empty");
	if (self = [super init])
	{
		[self setTileSideLength:kDefaultCloudMadeSize];
		accessKey = developerAccessKey;
		if (styleNumber > 0)
			cloudmadeStyleNumber = styleNumber;
		else
			cloudmadeStyleNumber = kDefaultCloudMadeStyleNumber;
	}
	[self requestToken];
	return self;
}

- (NSString*) tileURL: (RMTile) tile
{
	NSAssert4(((tile.zoom >= self.minZoom) && (tile.zoom <= self.maxZoom)),
			  @"%@ tried to retrieve tile with zoomLevel %d, outside source's defined range %f to %f", 
			  self, tile.zoom, self.minZoom, self.maxZoom);
	NSAssert(accessToken,@"CloudMade access token must be non-empty");
	return [NSString stringWithFormat:@"http://tile.cloudmade.com/%@/%d/%d/%d/%d/%d.png?token=%@",
			accessKey,
			cloudmadeStyleNumber,
			kDefaultCloudMadeSize, tile.zoom, tile.x, tile.y,accessToken];
}

-(NSString*) uniqueTilecacheKey
{
	return [NSString stringWithFormat:@"CloudMadeMaps%d", cloudmadeStyleNumber];
}

-(NSString *)shortName
{
	return [NSString stringWithFormat:@"Cloud Made %d", cloudmadeStyleNumber];
}
-(NSString *)longDescription
{
	return @"CloudMade.com provides high quality renderings of Open Street Map data";
}
-(NSString *)shortAttribution
{
	return @"© 2009 CloudMade.com";
}
-(NSString *)longAttribution
{
	return @"Map © CloudMade.com. Map data CCBYSA 2009 OpenStreetMap.org contributors.";
}

@end
