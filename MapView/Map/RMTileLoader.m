//
//  RMTimeImageSet.m
//
// Copyright (c) 2008, Route-Me Contributors
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

#import "RMTileLoader.h"

#import "RMTileImage.h"
#import "RMTileSource.h"
#import "RMPixel.h"
#import "RMMercatorToScreenProjection.h"
#import "RMFractalTileProjection.h"
#import "RMTileImageSet.h"

#import "RMTileCache.h"

NSString* const RMMapImageRemovedFromScreenNotification = @"RMMapImageRemovedFromScreen";
NSString* const RMMapImageAddedToScreenNotification = @"RMMapImageAddedToScreen";

NSString* const RMSuspendExpensiveOperations = @"RMSuspendExpensiveOperations";
NSString* const RMResumeExpensiveOperations = @"RMResumeExpensiveOperations";

NSString* const RMTileRetrieved = @"RMTileRetrieved";
NSString* const RMTileRequested = @"RMTileRequested";

@implementation RMTileLoader

@synthesize loadedBounds, loadedZoom;

-(id) init
{
	if (![self initWithContent: nil])
		return nil;
	
	return self;
}

-(id) initWithContent: (RMMapContents *)_contents
{
	if (![super init])
		return nil;
	
	content = _contents;
	
	[self clearLoadedBounds];
	loadedTiles.origin.tile = RMTileDummy();
	
	suppressLoading = NO;
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) clearLoadedBounds
{
	loadedBounds = CGRectMake(0, 0, 0, 0);
	//	loadedTiles.origin.tile = RMTileDummy();
}
-(BOOL) screenIsLoaded
{
	//	RMTileRect targetRect = [content tileBounds];
	BOOL contained = CGRectContainsRect(loadedBounds, [content screenBounds]);
	
	int targetZoom = (int)([[content mercatorToTileProjection] calculateNormalisedZoomFromScale:[content scale]]);
	
	if (contained == NO)
	{
		//		NSLog(@"reassembling because its not contained");
	}
	
	if (targetZoom != loadedZoom)
	{
		//		NSLog(@"reassembling because target zoom = %f, loaded zoom = %d", targetZoom, loadedZoom);
	}
	
	return contained && targetZoom == loadedZoom;
}


-(void) updateLoadedImages
{
	if (suppressLoading)
		return;
	
	if ([content mercatorToTileProjection] == nil || [content  
													  mercatorToScreenProjection] == nil)
		return;
	
	// delay display of new images until expensive operations are  
	//allowed
	[[NSNotificationCenter defaultCenter] removeObserver:self  
													name:RMResumeExpensiveOperations object:nil];
	if ([RMMapContents performExpensiveOperations] == NO)
	{
        [[NSNotificationCenter defaultCenter] addObserver:self  
												 selector:@selector(updateLoadedImages)  
													 name:RMResumeExpensiveOperations object:nil];
        return;
	}
	
	if ([self screenIsLoaded])
		return;
	
	//      NSLog(@"assemble count = %d", [[content imagesOnScreen] count]);
	
	RMTileRect newTileRect = [content tileBounds];
	
	RMTileImageSet *images = [content imagesOnScreen];
	CGRect newLoadedBounds = [images addTiles:newTileRect ToDisplayIn:
							  [content screenBounds]];
	
	if (!RMTileIsDummy(loadedTiles.origin.tile))
		[images removeTiles:loadedTiles];
	
	//      NSLog(@"-> count = %d", [images count]);
	
	loadedBounds = newLoadedBounds;
	loadedZoom = newTileRect.origin.tile.zoom;
	loadedTiles = newTileRect;
	
	[content tilesUpdatedRegion:newLoadedBounds];

} 

/*
-(void) updateLoadedImages
{
	if (suppressLoading)
		return;
	
	if ([content mercatorToTileProjection] == nil || [content mercatorToScreenProjection] == nil)
		return;
	
	if ([self screenIsLoaded])
		return;
	
	//	NSLog(@"assemble count = %d", [[content imagesOnScreen] count]);
	
	RMTileRect newTileRect = [content tileBounds];
	
	RMTileImageSet *images = [content imagesOnScreen];
	CGRect newLoadedBounds = [images addTiles:newTileRect ToDisplayIn:[content screenBounds]];
	
	if (!RMTileIsDummy(loadedTiles.origin.tile))
		[images removeTiles:loadedTiles];
	
	//	NSLog(@"-> count = %d", [images count]);
	
	loadedBounds = newLoadedBounds;
	loadedZoom = newTileRect.origin.tile.zoom;
	loadedTiles = newTileRect;
	
	[content tilesUpdatedRegion:newLoadedBounds];
}*/

- (void)moveBy: (CGSize) delta
{
	//	NSLog(@"loadedBounds %f %f %f %f -> ", loadedBounds.origin.x, loadedBounds.origin.y, loadedBounds.size.width, loadedBounds.size.height);
	loadedBounds = RMTranslateCGRectBy(loadedBounds, delta);
	//	NSLog(@" -> %f %f %f %f", loadedBounds.origin.x, loadedBounds.origin.y, loadedBounds.size.width, loadedBounds.size.height);
	[self updateLoadedImages];
}

- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center
{
	loadedBounds = RMScaleCGRectAboutPoint(loadedBounds, zoomFactor, center);
	[self updateLoadedImages];
}

- (BOOL) suppressLoading
{
	return suppressLoading;
}

- (void) setSuppressLoading: (BOOL) suppress
{
	suppressLoading = suppress;
	
	if (suppress == NO)
		[self updateLoadedImages];
}

- (void)reload
{
	[self clearLoadedBounds];
	[self updateLoadedImages];
}

//-(BOOL) containsRect: (CGRect)bounds
//{
//	return CGRectContainsRect(loadedBounds, bounds);
//}

@end
