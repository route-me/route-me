//
//  RMWebTileImage.m
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

#import "RMWebTileImage.h"
#import <QuartzCore/CALayer.h>

#import "RMMapContents.h"
#import "RMTileLoader.h"

NSString *RMWebTileImageErrorDomain = @"RMWebTileImageErrorDomain";
NSString *RMWebTileImageHTTPResponseCodeKey = @"RMWebTileImageHTTPResponseCodeKey";
NSString *RMWebTileImageNotificationErrorKey = @"RMWebTileImageNotificationErrorKey";


@implementation RMWebTileImage

- (id) initWithTile: (RMTile)_tile FromURL:(NSString*)urlStr
{
	if (![super initWithTile:_tile])
		return nil;
	
	url = [[NSURL alloc] initWithString:urlStr];

        connection = nil;
		
	data =[[NSMutableData alloc] initWithCapacity:0];
	
	retries = kWebTileRetries;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:RMTileRequested object:self];

	[self requestTile];
	
	return self;
}

- (void) dealloc
{
	[self cancelLoading];
	
	[data release];
	data = nil;
	
	[url release];
	url = nil;
	
	[super dealloc];
}

- (void) requestTile
{
	//RMLog(@"fetching: %@", url);
	if(connection) // re-request
	{
		//RMLog(@"Refetching: %@: %d", url, retries);
		
		[connection release];
		connection = nil;

		if(retries == 0) // No more retries
		{
			[super displayProxy:[RMTileProxy errorTile]];
			[[NSNotificationCenter defaultCenter] postNotificationName:RMTileRetrieved object:self];

			[[NSNotificationCenter defaultCenter] postNotificationName:RMTileError object:self userInfo:[NSDictionary dictionaryWithObject:lastError forKey:RMWebTileImageNotificationErrorKey]];
            [lastError autorelease]; lastError = nil;

			return;
		}
		retries--;		

		[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startLoading:) userInfo:nil repeats:NO];		
	}
	else 
	{
		[self startLoading:nil];
	}
}

- (void) startLoading:(NSTimer *)timer
{
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
	
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	
	if (!connection)
	{
		[super displayProxy:[RMTileProxy errorTile]];
		[[NSNotificationCenter defaultCenter] postNotificationName:RMTileRetrieved object:self];
	}
}

- (void) cancelLoading
{
	if (!connection)
		return;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:RMTileRetrieved object:self];
	[connection cancel];
	
	[connection release];
	connection = nil;
	
    if ( lastError ) [lastError release]; lastError = nil;
    
	[super cancelLoading];
}

#pragma mark URL loading functions
// Delegate methods for loading the image

//– connection:didCancelAuthenticationChallenge:  delegate method  
//– connection:didReceiveAuthenticationChallenge:  delegate method  
//Connection Data and Responses
//– connection:willCacheResponse:  delegate method  
//– connection:didReceiveResponse:  delegate method  
//– connection:didReceiveData:  delegate method  
//– connection:willSendRequest:redirectResponse:  delegate method  
//Connection Completion
//– connection:didFailWithError:  delegate method
//– connectionDidFinishLoading:  delegate method 

- (void)connection:(NSURLConnection *)_connection didReceiveResponse:(NSURLResponse *)response
{
	int statusCode = NSURLErrorUnknown; // unknown

	if([response isKindOfClass:[NSHTTPURLResponse class]])
	  statusCode = [(NSHTTPURLResponse*)response statusCode];
		
	[data setLength:0];
	
        /// \bug magic number
	if(statusCode < 400) // Success
	{
	}
        /// \bug magic number
	else if(statusCode == 404) // Not Found
	{
        [super displayProxy:[RMTileProxy missingTile]];
        
        NSError *error = [NSError errorWithDomain:RMWebTileImageErrorDomain 
                                             code:RMWebTileImageErrorNotFoundResponse
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   NSLocalizedString(@"The requested tile was not found on the server", @""), NSLocalizedDescriptionKey, nil]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:RMTileError object:self userInfo:[NSDictionary dictionaryWithObject:error forKey:RMWebTileImageNotificationErrorKey]];
		[self cancelLoading];
	}
	else // Other Error
	{
		//RMLog(@"didReceiveResponse %@ %d", _connection, statusCode);

		BOOL retry = FALSE;
		
		switch(statusCode)
		{
                        /// \bug magic number
			case 500: retry = TRUE; break;
			case 503: retry = TRUE; break;
		}
		
        NSError *error = [NSError errorWithDomain:RMWebTileImageErrorDomain 
                                             code:RMWebTileImageErrorUnexpectedHTTPResponse 
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [NSNumber numberWithInt:statusCode], RMWebTileImageHTTPResponseCodeKey,
                                                   [NSString stringWithFormat:NSLocalizedString(@"The server returned error code %d", @""), statusCode], NSLocalizedDescriptionKey, nil]];
        
		if(retry)
		{
            if ( lastError ) [lastError release];
            lastError = [error retain];
			[self requestTile];
		}
		else 
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:RMTileError object:self userInfo:[NSDictionary dictionaryWithObject:error forKey:RMWebTileImageNotificationErrorKey]];
			[self cancelLoading];
		}
	}
}

- (void)connection:(NSURLConnection *)_connection didReceiveData:(NSData *)newData
{
	[data appendData:newData];
}

- (void)connection:(NSURLConnection *)_connection didFailWithError:(NSError *)error
{
	//RMLog(@"didFailWithError %@ %d %@", _connection, [error code], [error localizedDescription]);

	BOOL retry = FALSE;
	
	switch([error code])
	{
          case NSURLErrorBadURL:                      // -1000
          case NSURLErrorTimedOut:                    // -1001
          case NSURLErrorUnsupportedURL:              // -1002
          case NSURLErrorCannotFindHost:              // -1003
          case NSURLErrorCannotConnectToHost:         // -1004
          case NSURLErrorNetworkConnectionLost:       // -1005
          case NSURLErrorDNSLookupFailed:             // -1006
          case NSURLErrorResourceUnavailable:         // -1008
          case NSURLErrorNotConnectedToInternet:      // -1009
            retry = TRUE; 
            break;
	}
	
	if(retry)
	{
        if ( lastError ) [lastError release];
        lastError = [error retain];
        
		[self requestTile];
	}
	else 
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:RMTileError object:self userInfo:[NSDictionary dictionaryWithObject:error forKey:RMWebTileImageNotificationErrorKey]];
		[self cancelLoading];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)_connection
{
	if ([data length] == 0) {
		//RMLog(@"connectionDidFinishLoading %@ data size %d", _connection, [data length]);
        
        if ( lastError ) [lastError release];
        lastError = [[NSError errorWithDomain:RMWebTileImageErrorDomain 
                                         code:RMWebTileImageErrorZeroLengthResponse
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                               NSLocalizedString(@"The server returned a zero-length response", @""), NSLocalizedDescriptionKey, nil]] retain];
		[self requestTile];
	}
	else
	{
		[self updateImageUsingData:data];
		
		[data release];
		data = nil;
		[url release];
		url = nil;
		[connection release];
		connection = nil;
		if ( lastError ) [lastError release]; lastError = nil;
        
		[[NSNotificationCenter defaultCenter] postNotificationName:RMTileRetrieved object:self];
	}
}

@end
