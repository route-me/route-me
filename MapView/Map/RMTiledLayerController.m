//
//  RMTiledLayerController.m
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
#import "RMGlobalConstants.h"
#import "RMTiledLayerController.h"
#import "RMFractalTileProjection.h"
#import "RMTileSource.h"

@implementation RMTiledLayerController

@synthesize layer;

-(id) initWithTileSource: (id <RMTileSource>) _tileSource
{
	if (![super init])
		return nil;
	
	@throw [NSException exceptionWithName:@"NotImplementedExcption" reason:@"TiledLayerController is not complete. Use CoreAnimationRenderer instead." userInfo:nil];

	tileSource = _tileSource;
	[tileSource retain];
	RMFractalTileProjection *tileProjection = [tileSource tileProjection];
	
	layer = [CATiledLayer layer];
	layer.delegate = self;

	layer.levelsOfDetail = tileProjection.maxZoom + 1; // check this.
	layer.levelsOfDetailBias = 1; // Allows zoom level 0.
	
	layer.tileSize = CGSizeMake(tileProjection.tileSideLength,
								tileProjection.tileSideLength);
	
	RMXYRect boundsRect = tileProjection.bounds;
	layer.bounds = CGRectMake(boundsRect.origin.x, boundsRect.origin.y, boundsRect.size.width, boundsRect.size.height) ;
	layer.position = kTheOrigin;

	[self setScale:1];
	[layer setNeedsDisplay];
	
	return self;
}

-(void) dealloc
{
	layer.delegate = nil;
	[layer release];
	
	[super dealloc];
}

-(void) setScale: (float) _scale
{
	scale = _scale;
	layer.transform = CATransform3DMakeScale(1/scale,1/scale, 1.0f);
}

- (float) scale
{
	return scale;
}

-(void) centerProjectedPoint: (RMProjectedPoint) aPoint animate: (BOOL) animate
{
	if (animate == NO)
	{
		[CATransaction begin];
		[CATransaction setValue:[NSNumber numberWithFloat:0.0f]
						 forKey:kCATransactionAnimationDuration];
	}
	
//	layer.position = CGPointMake(point.x, point.y);

	if (animate == NO)
	{
		[CATransaction commit];
	}
	
//	topLeft = point;
//	topLeft.x -= viewSize.width * scale / 2;
//	topLeft.y -= viewSize.height * scale / 2;
}

-(void) centerLatLong: (CLLocationCoordinate2D) aPoint animate: (BOOL) animate
{
	[self centerMercator:[RMMercator toMercator:aPoint] animate: animate];
}

-(void) dragBy: (CGSize) delta
{	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:0.0f]
					 forKey:kCATransactionAnimationDuration];
	
	layer.position = CGPointMake(layer.position.x + delta.width,
									  layer.position.y + delta.height);
	[CATransaction commit];
}

-(void) zoomByFactor: (float) zoomFactor near:(CGPoint) center
{
	[self setScale: scale * zoomFactor];
}

- (void)drawLayer:(CALayer *)theLayer
        inContext:(CGContextRef)theContext
{
	RMLog(@"drawLayer:inContext:");
	
	//	CGRect visibleRect = [self visibleRect];
	//	RMLog(@"visibleRect: %d %d %d %d", visibleRect.origin.x, visibleRect.origin.y, visibleRect.size.width, visibleRect.size.height);
	
	CGRect rect = CGContextGetClipBoundingBox(theContext);
	//	RMLog(@"rect: %d %d %d %d", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
	
	//CGAffineTransform transform = CGContextGetCTM(theContext);
	//	RMLog(@"transform scale: a:%f b:%f c:%f d:%f tx:%f ty:%f", transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty);

	/// \bug magic string literals
	NSString *path = [[NSBundle mainBundle] pathForResource:@"loading" ofType:@"png"];
	CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename([path UTF8String]);
	CGImageRef image = CGImageCreateWithPNGDataProvider(dataProvider, NULL, FALSE, kCGRenderingIntentDefault);
	CGDataProviderRelease(dataProvider);
	
	CGContextDrawImage(theContext, rect, image);
}

- (void)setFrame:(CGRect)frame
{
}

- (CALayer*) layer
{
	return layer;
}

@end
