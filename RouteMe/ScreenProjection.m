//
//  ScreenProjection.m
//  Images
//
//  Created by Joseph Gentle on 28/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ScreenProjection.h"


@implementation ScreenProjection

-(id) initWithSize: (CGSize) size
{
	if (![super init])
		return nil;
	viewSize = size;
	topLeft.x = 0;
	topLeft.y = 0;
	scale = 1;
	return self;
}

-(void) centerMercator: (MercatorPoint) point
{
	topLeft = point;
	topLeft.x -= viewSize.width * scale / 2;
	topLeft.y -= viewSize.height * scale / 2;
}

-(void) centerLatLong: (CLLocationCoordinate2D) point;
{
	[self centerMercator:[Mercator toMercator:point]];
}

-(void) dragBy: (CGSize) delta
{
	topLeft.x -= delta.width * scale;
	topLeft.y += delta.height * scale;
}

-(void) zoomByFactor: (double) zoomFactor Near:(CGPoint) center
{
//	NSLog(@"zoomBy: %f", zoomFactor);
	topLeft.x += center.x * scale;
	topLeft.y += (viewSize.height - center.y) * scale;
	scale *= zoomFactor;
	topLeft.x -= center.x * scale;
	topLeft.y -= (viewSize.height - center.y) * scale;
/*
	topLeft = [self projectInversePoint: center];
	
	scale *= zoomFactor;
	
	CGPoint minusCenter;
	minusCenter.x = -center.x;
	minusCenter.y = -center.y;
	topLeft = [self projectInversePoint: minusCenter];*/
}

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
}

@synthesize scale;
@synthesize viewSize;
@end
