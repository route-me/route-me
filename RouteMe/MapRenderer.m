//
//  MapRenderer.m
//  RouteMe
//
//  Created by Joseph Gentle on 9/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MapRenderer.h"
#import "ScreenProjection.h"
#import "FractalTileProjection.h"
#import "MapView.h"
#import "TileSource.h"

@implementation MapRenderer

- (id) initWithView: (MapView *)_view
{
	if (![super init])
		return nil;
	
	view = _view;
	screenProjection = [[ScreenProjection alloc] initWithBounds:[view bounds]];
	
	CLLocationCoordinate2D here;
	here.latitude = -33.9464;
	here.longitude = 151.2381;
	[screenProjection setScale:[[[view tileSource] tileProjection] calculateScaleFromZoom:16]];
	[self moveToLatLong:here];
	
	return self;
}

- (void)drawRect:(CGRect)rect
{ }

-(void) moveToMercator: (MercatorPoint) point
{
	[screenProjection moveToMercator:point];
}
-(void) moveToLatLong: (CLLocationCoordinate2D) point
{
	[screenProjection moveToLatLong:point];
}

- (void)moveBy: (CGSize) delta
{
	[screenProjection moveBy:delta];
	[self setNeedsDisplay];
}

- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center
{
	[screenProjection zoomByFactor:zoomFactor Near:center];
	[self setNeedsDisplay];
}

- (void)setNeedsDisplay
{
	[view setNeedsDisplay];
}

- (double) scale
{
	return [screenProjection scale];
}

- (void) setScale: (double) scale
{
	[screenProjection setScale:scale];
}

@end
