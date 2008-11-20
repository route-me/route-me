//
//  RMPolygon.m
//  Shapes
//
//  Created by Joseph Gentle on 11/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMPath.h"
#import "RMMapView.h"
#import "RMMapContents.h"
#import "RMMercatorToScreenProjection.h"
#import "RMPixel.h"
#import "RMProjection.h"

@implementation RMPath

@synthesize origin;

- (id) initWithContents: (RMMapContents*)aContents
{
	if (![super init])
		return nil;
	
	contents = aContents;

	path = CGPathCreateMutable();
	
	lineWidth = 100.0f;
	drawingMode = kCGPathFillStroke;
	lineColor = [UIColor blackColor];
	fillColor = [UIColor redColor];
	self.masksToBounds = NO;
	
	scaleLineWidth = YES;
//	self.frame = CGRectMake(100, 100, 100, 100);
//	[self setNeedsDisplayOnBoundsChange:YES];
	
	return self;
}

- (id) initForMap: (RMMapView*)map
{
	return [self initWithContents:[map contents]];
}

-(void) dealloc
{
	CGPathRelease(path);
	
	[super dealloc];
}

- (id<CAAction>)actionForKey:(NSString *)key
{
	return nil;
}

- (void) recalculateGeometry
{
	float scale = [[contents mercatorToScreenProjection] scale];
	// The bounds are actually in mercators...
	CGRect boundsInMercators = CGPathGetBoundingBox(path);
	boundsInMercators.origin.x -= lineWidth;
	boundsInMercators.origin.y -= lineWidth;
	boundsInMercators.size.width += 2*lineWidth;
	boundsInMercators.size.height += 2*lineWidth;
	
	CGRect pixelBounds = RMScaleCGRectAboutPoint(boundsInMercators, 1.0f / scale, CGPointMake(0,0));

//	NSLog(@"old bounds: %f %f %f %f", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
	self.bounds = pixelBounds;
//	NSLog(@"new bounds: %f %f %f %f", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
	
//	NSLog(@"old position: %f %f", self.position.x, self.position.y);
	self.position = [[contents mercatorToScreenProjection] projectXYPoint: origin];
//	NSLog(@"new position: %f %f", self.position.x, self.position.y);

//	NSLog(@"Old anchor point %f %f", self.anchorPoint.x, self.anchorPoint.y);
	self.anchorPoint = CGPointMake(-pixelBounds.origin.x / pixelBounds.size.width,-pixelBounds.origin.y / pixelBounds.size.height);
//	NSLog(@"new anchor point %f %f", self.anchorPoint.x, self.anchorPoint.y);
}

- (void) addLineToXY: (RMXYPoint) point
{
//	NSLog(@"addLineToXY %f %f", point.x, point.y);
	
	NSValue* value = [NSValue value:&point withObjCType:@encode(RMXYPoint)];

	if (points == nil)
	{
		points = [[NSMutableArray alloc] init];
		[points addObject:value];
		origin = point;
	
		self.position = [[contents mercatorToScreenProjection] projectXYPoint: origin];
//		NSLog(@"screen position set to %f %f", self.position.x, self.position.y);
		CGPathMoveToPoint(path, NULL, 0.0f, 0.0f);
	}
	else
	{
		[points addObject:value];
		
		point.x = point.x - origin.x;
		point.y = point.y - origin.y;
		
		CGPathAddLineToPoint(path, NULL, point.x, -point.y);
	
		[self recalculateGeometry];
	}
	[self setNeedsDisplay];
}

- (void) addLineToScreenPoint: (CGPoint) point
{
	RMXYPoint mercator = [[contents mercatorToScreenProjection] projectScreenPointToXY: point];
	
	[self addLineToXY: mercator];
}

- (void) addLineToLatLong: (RMLatLong) point
{
	RMXYPoint mercator = [[contents projection] latLongToPoint:point];
	
	[self addLineToXY:mercator];
}

- (void)drawInContext:(CGContextRef)theContext
{
	renderedScale = [contents scale];
	
//	CGContextFillRect(theContext, self.bounds);//CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
	
	float scale = 1.0f / [contents scale];
	
	CGContextScaleCTM(theContext, scale, scale);
	
	CGContextBeginPath(theContext);
	CGContextAddPath(theContext, path);
	
	CGContextSetLineWidth(theContext, lineWidth);
	CGContextSetStrokeColorWithColor(theContext, [lineColor CGColor]);
	CGContextSetFillColorWithColor(theContext, [fillColor CGColor]);
	CGContextDrawPath(theContext, drawingMode);
	CGContextClosePath(theContext);
}

- (void) closePath
{
	CGPathCloseSubpath(path);
}

- (float) lineWidth
{
	return lineWidth;
}

- (void) setLineWidth: (float) newLineWidth
{
	lineWidth = newLineWidth;
	[self recalculateGeometry];
	[self setNeedsDisplay];
}

- (CGPathDrawingMode) drawingMode
{
	return drawingMode;
}

- (void) setDrawingMode: (CGPathDrawingMode) newDrawingMode
{
	drawingMode = newDrawingMode;
	[self setNeedsDisplay];
}

- (UIColor*) lineColor
{
	return lineColor;
}

- (void) setLineColor: (UIColor*) newLineColor
{
	lineColor = newLineColor;
	[self setNeedsDisplay];
}

- (UIColor*) fillColor
{
	return fillColor;
}

- (void) setFillColor: (UIColor*) newFillColor
{
	fillColor = newFillColor;
	[self setNeedsDisplay];
}

- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) pivot
{
	[super zoomByFactor:zoomFactor near:pivot];
	
	float newScale = [contents scale];
	if (newScale / renderedScale >= 2.0f
		|| newScale / renderedScale <= 0.4f)
	{
		[self setNeedsDisplay];
	}
}

@end
