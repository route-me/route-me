//
//  WebTileImage.h
//  Images
//
//  Created by Joseph Gentle on 1/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TileImage.h"

@interface WebTileImage : TileImage {
	// Before image is completely loaded a proxy image can be used.
	// This will typically be a boilerplate image or a zoomed in or zoomed out version of another image.
	TileImage *proxy;
	
	NSURLConnection *connection;
	// Data accumulator during loading.
	NSMutableData *data;
}

- (id) initWithTile: (Tile)tile FromURL:(NSString*)url;

@end
