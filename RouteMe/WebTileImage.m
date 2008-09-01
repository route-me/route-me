//
//  WebTileImage.m
//  Images
//
//  Created by Joseph Gentle on 1/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "WebTileImage.h"
#import "TileProxy.h"

@implementation WebTileImage

- (id) initFromURL:(NSString*)urlStr
{
	if (![super init])
		return nil;

	[delegate retain];
	
	NSLog(@"Loading image from URL %@ ...", urlStr);
	NSURL *url = [NSURL URLWithString: urlStr];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSCachedURLResponse *cachedData = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
	
	//	NSURLCache *cache = [NSURLCache sharedURLCache];
	//	NSLog(@"Cache mem size: %d / %d disk size: %d / %d", [cache currentMemoryUsage], [cache memoryCapacity], [cache currentDiskUsage], [cache diskCapacity]);
	
	if (cachedData != nil)
	{
		NSLog(@"Using cached image");
		[self setImageToData:[cachedData data]];
		//NSData *imageData = [cachedData data];
		//image = [UIImage imageWithData:imageData];
		//[image retain];
	}
	else
	{
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
		
		if (connection == nil)
		{
			NSLog(@"Error: Connection is nil ?!?");
			proxy = [TileProxy errorTile];
		}
		else
		{
			proxy = [TileProxy loadingTile];
		}
	}
	
	//	NSLog(@"... done. data size = %d", [imageData length]);
	
	return self;
}

-(void) dealloc
{
	NSLog(@"Image dealloced");
	[proxy release];
	[delegate release];

	if (connection != nil)
	{
		[self cancelLoading];
	}
	[super dealloc];
}

-(void) cancelLoading
{
	if (connection == nil)
		return;
		
	NSLog(@"Image loading cancelled");
	[connection cancel];
	
	[connection release];
	connection = nil;

	[data release];
	data = nil;
}

- (void)drawInRect:(CGRect)rect
{
	if (image)
		[super drawInRect:rect];
	else
		[proxy drawInRect:rect];
}

- (void)setDelegate:(id) _delegate
{
	delegate = [_delegate retain];
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
	proxy = [TileProxy errorTile];
	[data release];
	data = nil;
	NSLog(@"Tile could not be loaded: %@", [error localizedDescription]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)_connection
{
	[self setImageToData:data];
//	image = [UIImage imageWithData:data];
//	[image retain];
	
	[data release];
	data = nil;
	[connection release];
	connection = nil;
	[delegate tileDidFinishLoading: self];
	NSLog(@"finished loading image");
}

- (id) release
{
	if ([self retainCount] == 2 && connection != nil)
	{
		[self cancelLoading];
	}
	[super release];
	return self;
}

@end
