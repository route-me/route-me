//
//  WebTileImage.m
//  Images
//
//  Created by Joseph Gentle on 1/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMWebTileImage.h"
#import "RMTileProxy.h"
#import <QuartzCore/CALayer.h>

#import "RMMapContents.h"
#import "RMTileLoader.h"

@implementation RMWebTileImage

- (id) initWithTile: (RMTile)_tile FromURL:(NSString*)urlStr
{
	if (![super initWithTile:_tile])
		return nil;

//	NSLog(@"Loading image from URL %@ ...", urlStr);
	NSURL *url = [NSURL URLWithString: urlStr];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSCachedURLResponse *cachedData = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
	
	proxy = [RMTileProxy loadingTile];
	[proxy retain];
	
	//	NSURLCache *cache = [NSURLCache sharedURLCache];
	//	NSLog(@"Cache mem size: %d / %d disk size: %d / %d", [cache currentMemoryUsage], [cache memoryCapacity], [cache currentDiskUsage], [cache diskCapacity]);
	
	if (cachedData != nil)
	{
//		NSLog(@"Using cached image");
		[self setImageToData:[cachedData data]];
	}
	else
	{
		BOOL startImmediately = [RMMapContents performExpensiveOperations];
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:startImmediately];
		
		if (connection == nil)
		{
			NSLog(@"Error: Connection is nil ?!?");
			proxy = [RMTileProxy errorTile];
			[proxy retain];
		}
		
		if (startImmediately == NO)
		{
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startLoadingImage:) name:RMResumeExpensiveOperations object:nil];
		}
	}

	//	NSLog(@"... done. data size = %d", [imageData length]);
	
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
	
//	NSLog(@"Image dealloced");
	[proxy release];
	
//	NSLog(@"loading cancelled because image dealloced");
	[self cancelLoading];
	
	[super dealloc];
}

-(void) cancelLoading
{
	if (connection == nil)
		return;
		
//	NSLog(@"Image loading cancelled");
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
	else
		[proxy drawInRect:rect];
}

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
	if (data != nil)
		[data release];
	
	data = [[NSMutableData alloc] initWithCapacity:[response expectedContentLength]];
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
	proxy = [RMTileProxy errorTile];
	[data release];
	data = nil;
	NSLog(@"Tile could not be loaded: %@", [error localizedDescription]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)_connection
{
	[self setImageToData:data];

	[data release];
	data = nil;
	[connection release];
	connection = nil;
//	NSLog(@"finished loading image");
}

@end
