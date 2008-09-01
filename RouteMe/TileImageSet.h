//
//  TimeImageSet.h
//  Images
//
//  Created by Joseph Gentle on 29/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tile.h"

@class TileImage;
@class TileSource;

@interface TileImageSet : NSObject {
	// Set of locatedtileimages
	NSMutableSet *images;
	NSMutableSet *buffer;
	BOOL dirty;
}

-(id) initFromRect:(TileRect) rect FromImageSource: (TileSource*)source ToDisplayWithSize:(CGSize)screenBounds WithTileDelegate: (id)delegate;
-(void) dealloc;

// Invalidate all current image data.
-(void) setNeedsRedraw;

-(BOOL) needsRedraw;

// Slide all images by amount. Returns whether images still fill bounds.
-(BOOL) slideBy: (CGSize) amount Within: (CGRect)bounds;

-(void) assembleFromRect:(TileRect) rect FromImageSource: (TileSource*)source ToDisplayWithSize:(CGSize)viewSize WithTileDelegate: (id)delegate;
-(void) draw;

@end
