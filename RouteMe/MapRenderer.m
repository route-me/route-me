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

#import "TileImage.h"

@implementation MapRenderer

@synthesize screenProjection;

// Designated initialiser
- (id) initWithView: (MapView *)_view ProjectingIn: (ScreenProjection*) _screenProjection
{
	if (![super init])
		return nil;
	
	view = _view;
	screenProjection = [_screenProjection retain];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapImageLoaded:) name:MapImageLoadedNotification object:nil];
	
	return self;
}

- (id) initWithView: (MapView *)_view
{
	ScreenProjection *_screenProjection = [[ScreenProjection alloc] initWithBounds:[_view bounds]];
	return [self initWithView:_view ProjectingIn:_screenProjection];
}


-(void) dealloc
{
	[screenProjection release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

-(void)mapImageLoaded: (NSNotification*)notification
{
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{ }

-(void) moveToMercator: (MercatorPoint) point
{
	[screenProjection moveToMercator:point];
	[self setNeedsDisplay];
}
-(void) moveToLatLong: (CLLocationCoordinate2D) point
{
	[screenProjection moveToLatLong:point];
	[self setNeedsDisplay];
}

- (void)moveBy: (CGSize) delta
{
	[screenProjection moveBy:delta];
	[view setNeedsDisplay];
}

- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center
{
	[screenProjection zoomByFactor:zoomFactor Near:center];
	[view setNeedsDisplay];
}

-(void) recalculateImageSet
{
}

- (void)setNeedsDisplay
{
	[self recalculateImageSet];
	[view setNeedsDisplay];
}

- (double) scale
{
	return [screenProjection scale];
}

- (void) setScale: (double) scale
{
	[screenProjection setScale:scale];
	[self setNeedsDisplay];
}

@end
