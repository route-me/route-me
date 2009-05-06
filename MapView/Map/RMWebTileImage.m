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
#import "RMTileProxy.h"
#import <QuartzCore/CALayer.h>

#import "RMMapContents.h"
#import "RMTileLoader.h"

@implementation RMWebTileImage

@synthesize proxy;

- (id) initWithTile: (RMTile)_tile FromURL:(NSString*)urlStr
{
	if (![super initWithTile:_tile])
		return nil;

//	RMLog(@"Loading image from URL %@ ...", urlStr);
	NSURL *url = [NSURL URLWithString: urlStr];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSCachedURLResponse *cachedData = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
	
	self.proxy = [RMTileProxy loadingTile];
	
	//	NSURLCache *cache = [NSURLCache sharedURLCache];
	//	RMLog(@"Cache mem size: %d / %d disk size: %d / %d", [cache currentMemoryUsage], [cache memoryCapacity], [cache currentDiskUsage], [cache diskCapacity]);
	
	if (cachedData != nil)
	{
//		RMLog(@"Using cached image");
		[self updateImageUsingData:[cachedData data]];
	}
	else
	{
		BOOL startImmediately = [RMMapContents performExpensiveOperations];
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:startImmediately];

		if (connection == nil)
		{
			RMLog(@"Error: Connection is nil ?!?");
			self.proxy = [RMTileProxy errorTile];
		}
		else
		{
			//Notify whatever is interested that we have requested a tile
			[[NSNotificationCenter defaultCenter] postNotificationName:RMTileRequested object:nil];
		}
		
		if (startImmediately == NO)
		{
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startLoadingImage:) name:RMResumeExpensiveOperations object:nil];
		}
	}

	//	RMLog(@"... done. data size = %d", [imageData length]);
	
	return self;
}
			 
- (void) startLoadingImage: (NSNotification*)notification
{
	if (connection != nil)
	{
		[connection scheduleInRunLoop:[NSRunLoop currentRunLoop]
							  forMode:NSDefaultRunLoopMode];
		[connection start];
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:RMResumeExpensiveOperations object:nil];
}

-(void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
//	RMLog(@"Image dealloced");
  
  // we never retain so don't ever release it. The error and loading tiles are singletons
//	[proxy release];
	
//	RMLog(@"loading cancelled because image dealloced");
	[self cancelLoading];
	
	[super dealloc];
}

-(void) cancelLoading
{
	if (connection == nil)
		return;
		
//	RMLog(@"Image loading cancelled");
	[[NSNotificationCenter defaultCenter] postNotificationName:RMTileRetrieved object:nil];
	[connection cancel];
	
	[connection release];
	connection = nil;

	[data release];
	data = nil;
	
	[super cancelLoading];
}

- (void)makeLayer
{
	[super makeLayer];
	
	if (image == nil
		&& layer != nil
		&& layer.contents == nil)
	{
		layer.contents = (id)[[proxy image] CGImage];
	}
}
- (void)drawInRect:(CGRect)rect
{
	if (image)
		[super drawInRect:rect];
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

- (void)connection:(NSURLConnection *)_connection
didReceiveResponse:(NSURLResponse *)response
{
	if (data != nil)
		[data release];
	
	NSInteger contentLength = [response expectedContentLength];
	if (contentLength < 0) {
		contentLength = 0;
	}
	data = [[NSMutableData alloc] initWithCapacity:contentLength];
}

- (void)connection:(NSURLConnection *)_connection didReceiveData:(NSData *)newData
{
	[data appendData:newData];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)_connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
	return cachedResponse;
}

- (void)connection:(NSURLConnection *)_connection didFailWithError:(NSError *)error
{
	self.proxy = [RMTileProxy errorTile];
	[data release];
	data = nil;
	RMLog(@"Tile could not be loaded: %@", [error localizedDescription]);
	//If the tile failed, we still need to notify that this connection is done
	[[NSNotificationCenter defaultCenter] postNotificationName:RMTileRetrieved object:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)_connection
{
	[self updateImageUsingData:data];

	[data release];
	data = nil;
	[connection release];
	connection = nil;
//	RMLog(@"finished loading image");
	//Notify whatever is interested that we have retrieved a tile
	[[NSNotificationCenter defaultCenter] postNotificationName:RMTileRetrieved object:nil];
}

@end
