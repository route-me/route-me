//
//  WebTileImage.h
//  Images
//
//  Created by Joseph Gentle on 1/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMTileImage.h"

@interface RMWebTileImage : RMTileImage {
	// Before image is completely loaded a proxy image can be used.
	// This will typically be a boilerplate image or a zoomed in or zoomed out version of another image.
	RMTileImage *proxy;
	
	NSURLConnection *connection;
	// Data accumulator during loading.
	NSMutableData *data;
}

@property (assign, nonatomic) RMTileImage *proxy;

- (id) initWithTile: (RMTile)tile FromURL:(NSString*)url;

@end
