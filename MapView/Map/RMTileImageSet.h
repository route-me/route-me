//
//  RMTileImageSet.h
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

#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#	import <UIKit/UIKit.h>
#else
#	import <Cocoa/Cocoa.h>
#endif
#import "RMTile.h"

@class RMTileImage;
@protocol RMTileSource;

@protocol RMTileImageSetDelegate<NSObject>

@optional

-(void) tileRemoved: (RMTile) tile;
-(void) tileAdded: (RMTile) tile WithImage: (RMTileImage*) image;

@end

@interface RMTileImageSet : NSObject {
	IBOutlet id delegate;
	id<RMTileSource> tileSource;
	NSMutableSet *images;
	short zoom, tileDepth;
}

-(id) initWithDelegate: (id) _delegate;

-(void) addTile: (RMTile) tile WithImage: (RMTileImage *)image At: (CGRect) screenLocation;
-(void) addTile: (RMTile) tile At: (CGRect) screenLocation;
/// Add tiles inside rect protected to bounds. Return rectangle containing bounds extended to full tile loading area
-(CGRect) addTiles: (RMTileRect)rect ToDisplayIn:(CGRect)bounds;

-(RMTileImage*) imageWithTile: (RMTile) tile;
	
-(void) removeTile: (RMTile) tile;

-(void) removeAllTiles;

- (void) setTileSource: (id<RMTileSource>)newTileSource;

-(NSUInteger) count;

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center;

//- (void) drawRect:(CGRect) rect;

- (void) printDebuggingInformation;

- (void)cancelLoading;

-(void) tileImageLoaded:(NSNotification *)notification;
-(void) removeTilesWorseThan: (RMTileImage *)newImage;
-(BOOL) isTile: (RMTile)subject worseThanTile: (RMTile)object;
-(RMTileImage *) anyTileImage;
-(void) removeTilesOutsideOf: (RMTileRect)rect;

@property (assign, nonatomic, readwrite) id delegate;
// tileDepth defaults to zero. if tiles have no alpha, set this higher, 3 or so, to make zooming smoother
@property (assign, readwrite) short zoom, tileDepth;
@property (readonly) BOOL fullyLoaded;
@end
