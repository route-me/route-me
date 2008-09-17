//
//  ScreenProjection.m
//  Images
//
//  Created by Joseph Gentle on 28/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TiledLayerController.h"
#import "FractalTileProjection.h"
#import "TileSource.h"

@implementation TiledLayerController

@synthesize layer;

-(id) initWithTileSource: (id <TileSource>) _tileSource
{
	if (![super init])
		return nil;
	
	@throw [NSException exceptionWithName:@"NotImplementedExcption" reason:@"TiledLayerController is not complete. Use CoreAnimationRenderer instead." userInfo:nil];

	tileSource = _tileSource;
	[tileSource retain];
	FractalTileProjection *tileProjection = [tileSource tileProjection];
	
	layer = [CATiledLayer layer];
	layer.delegate = self;

	layer.levelsOfDetail = tileProjection.maxZoom + 1; // check this.
	layer.levelsOfDetailBias = 1; // Allows zoom level 0.
	
	layer.tileSize = CGSizeMake(tileProjection.tileSideLength,
								tileProjection.tileSideLength);
	
	MercatorRect mercBounds = tileProjection.bounds;
	layer.bounds = CGRectMake(mercBounds.origin.x, mercBounds.origin.y, mercBounds.size.width, mercBounds.size.height) ;
	layer.position = CGPointMake(0, 0);

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

-(void) centerMercator: (MercatorPoint) point Animate: (BOOL) animate
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

-(void) centerLatLong: (CLLocationCoordinate2D) point Animate: (BOOL) animate
{
	[self centerMercator:[Mercator toMercator:point] Animate: animate];
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

-(void) zoomByFactor: (float) zoomFactor Near:(CGPoint) center
{
//	NSLog(@"zoomBy: %f", zoomFactor);
/*	topLeft.x += center.x * scale;
	topLeft.y += (viewSize.height - center.y) * scale;
	scale *= zoomFactor;
	topLeft.x -= center.x * scale;
	topLeft.y -= (viewSize.height - center.y) * scale;
*/
	
	[self setScale: scale * zoomFactor];
	
}

- (void)drawLayer:(CALayer *)theLayer
        inContext:(CGContextRef)theContext
{
	NSLog(@"drawLayer:inContext:");
	
	//	CGRect visibleRect = [self visibleRect];
	//	NSLog(@"visibleRect: %d %d %d %d", visibleRect.origin.x, visibleRect.origin.y, visibleRect.size.width, visibleRect.size.height);
	
	CGRect rect = CGContextGetClipBoundingBox(theContext);
	//	NSLog(@"rect: %d %d %d %d", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
	
	//CGAffineTransform transform = CGContextGetCTM(theContext);
	//	NSLog(@"transform scale: a:%f b:%f c:%f d:%f tx:%f ty:%f", transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty);
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"loading" ofType:@"png"];
	CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename([path UTF8String]);
	CGImageRef image = CGImageCreateWithPNGDataProvider(dataProvider, NULL, FALSE, kCGRenderingIntentDefault);
	
	CGContextDrawImage(theContext, rect, image);
}

/*
-(CGPoint) projectMercatorPoint: (MercatorPoint) mercator
{
	CGPoint point;
	point.x = (mercator.x - topLeft.x) / scale;
	point.y = -(mercator.y - topLeft.y) / scale;
	return point;
}

-(CGRect) projectMercatorRect: (MercatorRect) mercator
{
	CGRect rect;
	rect.origin = [self projectMercatorPoint: mercator.origin];
	mercator.size.width = rect.size.width / scale;
	mercator.size.height = rect.size.height / scale;
	return rect;
}

-(MercatorPoint) projectInversePoint: (CGPoint) point
{
	MercatorPoint mercator;
	mercator.x = (scale * point.x) + topLeft.x;
	mercator.y = -(scale * point.y) + topLeft.y;
	return mercator;
}

-(MercatorRect) projectInverseRect: (CGRect) rect
{
	MercatorRect mercator;
	mercator.origin = [self projectInversePoint: rect.origin];
	mercator.size.width = rect.size.width * scale;
	mercator.size.height = rect.size.height * scale;
	return mercator;
}

-(MercatorRect) bounds
{
	MercatorRect rect;
	rect.origin = topLeft;
	rect.size.width = viewSize.width * scale;
	rect.size.height = viewSize.height * scale;
	return rect;
}*/

@end
