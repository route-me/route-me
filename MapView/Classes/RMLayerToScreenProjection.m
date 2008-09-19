//
//  LayerToScreenProjection.m
//  RouteMe
//
//  Created by Joseph Gentle on 11/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMLayerToScreenProjection.h"
#import <QuartzCore/QuartzCore.h>
#import "RMMathUtils.h"

@implementation RMLayerToScreenProjection

-(id) initWithBounds: (CGRect) _bounds InLayer: (CALayer *)_layer
{
	if (![super initWithBounds:_bounds])
		return nil;
	
	layer = [_layer retain];
	
	return self;
}

-(id) initWithBounds: (CGRect) bounds
{
	@throw([NSException exceptionWithName:@"InvalidInitialiser" reason:@"Use designated initialiser for LayertoScreenProjection" userInfo:nil]);
	[self dealloc];
	return nil;
}

-(void) dealloc
{
	[layer release];
	[super dealloc];
}

//	NSLog(@"Frame at %f %f %f,%f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);

//	frame = CGRectApplyAffineTransform(frame, CGAffineTransformInvert([layer affineTransform]));
//frame.origin.x -= layer.position.x;
//frame.origin.y -= layer.position.y;
//
//NSLog(@"Frame at %f %f %f,%f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);

-(void) moveToMercator: (RMMercatorPoint) point
{
	[super moveToMercator:point];
	NSLog(@"fix moveToMercator");
//	@throw([NSException exceptionWithName:@"NotImplemented" reason:@"method not yet implemented" userInfo:nil]);
}

- (void)moveBy: (CGSize) delta
{
	layer.position = RMTranslateCGPointBy(layer.position, delta);
	
	[super moveBy:delta];
}

// Center given in screen coordinates.
- (void)zoomByFactor: (float) factor Near:(CGPoint) center
{
	CATransform3D transform = layer.transform;
	transform = CATransform3DTranslate(transform, center.x, center.y, 0.0f);
	transform = CATransform3DScale(transform, factor, factor, 1.0f);
	transform = CATransform3DTranslate(transform, -center.x, -center.y, 0.0f);
	layer.transform = transform;
	
	[super zoomByFactor:factor Near:center];
}

- (void)zoomBy: (float) factor
{
	[self zoomByFactor:factor Near:CGPointMake(0,0)];
}

-(CGPoint) projectMercatorPoint: (RMMercatorPoint) merc
{
	NSLog(@"projectMercatorPoint");
	CGPoint point = [super projectMercatorPoint: merc];
	
	point.x -= layer.position.x;
	point.y -= layer.position.y;
	
	return point;
}
//-(CGRect) projectMercatorRect: (MercatorRect) rect
//{
//	CGRect rect = [super projectMercatorPoint: point];
//	
//	point.x -= layer.position.x;
//	point.y -= layer.position.y;
//	
//	return point;	
//}

//-(MercatorPoint) projectInversePoint: (CGPoint) point;
//-(MercatorRect) projectInverseRect: (CGRect) rect;

//-(MercatorRect) mercatorBounds;
//-(CGRect) screenBounds;

@end
