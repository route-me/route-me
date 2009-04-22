//
//  RMPath.m
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

#import "RMPath.h"
#import "RMMapView.h"
#import "RMMapContents.h"
#import "RMMercatorToScreenProjection.h"
#import "RMPixel.h"
#import "RMProjection.h"

@implementation RMPath

@synthesize origin;

/// \bug default values for lineWidth, lineColor, fillColor are hardcoded
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
    [self setLineColor:nil];
    [self setFillColor:nil];
	
	[super dealloc];
}

- (id<CAAction>)actionForKey:(NSString *)key
{
	return nil;
}

- (void) recalculateGeometry
{
	float scale = [[contents mercatorToScreenProjection] metersPerPixel];
	// The bounds are actually in mercators...
	/// \bug if "bounds are actually in mercators", shouldn't be using a CGRect
	CGRect boundsInMercators = CGPathGetBoundingBox(path);
	boundsInMercators.origin.x -= lineWidth;
	boundsInMercators.origin.y -= lineWidth;
	boundsInMercators.size.width += 2*lineWidth;
	boundsInMercators.size.height += 2*lineWidth;
	
	CGRect pixelBounds = RMScaleCGRectAboutPoint(boundsInMercators, 1.0f / scale, CGPointMake(0,0));

//	RMLog(@"old bounds: %f %f %f %f", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
	self.bounds = pixelBounds;
//	RMLog(@"new bounds: %f %f %f %f", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
	
//	RMLog(@"old position: %f %f", self.position.x, self.position.y);
	self.position = [[contents mercatorToScreenProjection] projectXYPoint: origin];
//	RMLog(@"new position: %f %f", self.position.x, self.position.y);

//	RMLog(@"Old anchor point %f %f", self.anchorPoint.x, self.anchorPoint.y);
	self.anchorPoint = CGPointMake(-pixelBounds.origin.x / pixelBounds.size.width,-pixelBounds.origin.y / pixelBounds.size.height);
//	RMLog(@"new anchor point %f %f", self.anchorPoint.x, self.anchorPoint.y);
}

- (void) addLineToXY: (RMProjectedPoint) point
{
//	RMLog(@"addLineToXY %f %f", point.easting, point.northing);
	
	NSValue* value = [NSValue value:&point withObjCType:@encode(RMProjectedPoint)];

	if (points == nil)
	{
		points = [[NSMutableArray alloc] init];
		[points addObject:value];
		origin = point;
	
		self.position = [[contents mercatorToScreenProjection] projectXYPoint: origin];
//		RMLog(@"screen position set to %f %f", self.position.x, self.position.y);
		CGPathMoveToPoint(path, NULL, 0.0f, 0.0f);
	}
	else
	{
		[points addObject:value];
		
		point.easting = point.easting - origin.easting;
		point.northing = point.northing - origin.northing;
		
		CGPathAddLineToPoint(path, NULL, point.easting, -point.northing);
	
		[self recalculateGeometry];
	}
	[self setNeedsDisplay];
}

- (void) addLineToScreenPoint: (CGPoint) point
{
	RMProjectedPoint mercator = [[contents mercatorToScreenProjection] projectScreenPointToXY: point];
	
	[self addLineToXY: mercator];
}

- (void) addLineToLatLong: (RMLatLong) point
{
	RMProjectedPoint mercator = [[contents projection] latLongToPoint:point];
	
	[self addLineToXY:mercator];
}

- (void)drawInContext:(CGContextRef)theContext
{
	renderedScale = [contents metersPerPixel];
	
	float scale = 1.0f / [contents metersPerPixel];
	
	CGContextScaleCTM(theContext, scale, scale);
	
	CGContextBeginPath(theContext);
	CGContextAddPath(theContext, path);
	
	CGContextSetLineWidth(theContext, lineWidth);
	CGContextSetStrokeColorWithColor(theContext, [lineColor CGColor]);
	CGContextSetFillColorWithColor(theContext, [fillColor CGColor]);
	
	// according to Apple's documentation, DrawPath closes the path if it's a filled style, so a call to ClosePath isn't necessary
	CGContextDrawPath(theContext, drawingMode);
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

- (UIColor *)lineColor
{
    return lineColor; 
}
- (void)setLineColor:(UIColor *)aLineColor
{
    if (lineColor != aLineColor) {
        [lineColor release];
        lineColor = [aLineColor retain];
		[self setNeedsDisplay];
    }
}

- (UIColor *)fillColor
{
    return fillColor; 
}
- (void)setFillColor:(UIColor *)aFillColor
{
    if (fillColor != aFillColor) {
        [fillColor release];
        fillColor = [aFillColor retain];
		[self setNeedsDisplay];
    }
}

- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) pivot
{
	[super zoomByFactor:zoomFactor near:pivot];
	
	float newMPP = [contents metersPerPixel];
	if (newMPP / renderedScale >= 2.0f
		|| newMPP / renderedScale <= 0.5f)
	{
		[self setNeedsDisplay];
	}
}

@end
