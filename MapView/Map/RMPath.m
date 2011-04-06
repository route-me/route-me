///
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

@synthesize scaleLineWidth;
@synthesize projectedLocation;
@synthesize enableDragging;
@synthesize enableRotation;
@synthesize lineDashPhase;
@synthesize scaleLineDash;

#define kDefaultLineWidth 2

- (id) initWithContents: (RMMapContents*)aContents
{
	if (![super init])
		return nil;
	
	contents = aContents;

	path = CGPathCreateMutable();
	
	lineWidth = kDefaultLineWidth;
	drawingMode = kCGPathFillStroke;
	lineCap = kCGLineCapButt;
	lineJoin = kCGLineJoinMiter;
	lineColor = [UIColor blackColor];
	fillColor = [UIColor redColor];
	_lineDashCount = 0;
    _lineDashLengths = NULL;
    _scaledLineDashLengths = NULL;
    lineDashPhase = 0.0;
    
	self.masksToBounds = YES;
	
	scaleLineWidth = NO;
    scaleLineDash = NO;
	enableDragging = YES;
	enableRotation = YES;
	isFirstPoint = YES;
	
    if ( [self respondsToSelector:@selector(setContentsScale:)] )
    {
        [(id)self setValue:[[UIScreen mainScreen] valueForKey:@"scale"] forKey:@"contentsScale"];
    }
	
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
	RMMercatorToScreenProjection *projection = [contents mercatorToScreenProjection];
	float scale = [projection metersPerPixel];
	float scaledLineWidth;
	CGPoint myPosition;
	CGRect pixelBounds, screenBounds;
	float offset;
	const float outset = 100.0f; // provides a buffer off screen edges for when path is scaled or moved
	
	// The bounds are actually in mercators...
	/// \bug if "bounds are actually in mercators", shouldn't be using a CGRect
	scaledLineWidth = lineWidth;
	if(!scaleLineWidth) {
		renderedScale = [contents metersPerPixel];
		scaledLineWidth *= renderedScale;
	}
	
	CGRect boundsInMercators = CGPathGetBoundingBox(path);
	boundsInMercators = CGRectInset(boundsInMercators, -scaledLineWidth, -scaledLineWidth);
	pixelBounds = CGRectInset(boundsInMercators, -scaledLineWidth, -scaledLineWidth);
	
	pixelBounds = RMScaleCGRectAboutPoint(pixelBounds, 1.0f / scale, CGPointZero);
	
	// Clip bound rect to screen bounds.
	// If bounds are not clipped, they won't display when you zoom in too much.
	myPosition = [projection projectXYPoint: projectedLocation];
	screenBounds = [contents screenBounds];
	
	// Clip top
	offset = myPosition.y + pixelBounds.origin.y - screenBounds.origin.y + outset;
	if(offset < 0.0f) {
		pixelBounds.origin.y -= offset;
		pixelBounds.size.height += offset;
	}
	// Clip left
	offset = myPosition.x + pixelBounds.origin.x - screenBounds.origin.x + outset;
	if(offset < 0.0f) {
		pixelBounds.origin.x -= offset;
		pixelBounds.size.width += offset;
	}
	// Clip bottom
	offset = myPosition.y + pixelBounds.origin.y + pixelBounds.size.height - screenBounds.origin.y - screenBounds.size.height - outset;
	if(offset > 0.0f) {
		pixelBounds.size.height -= offset;
	}
	// Clip right
	offset = myPosition.x + pixelBounds.origin.x + pixelBounds.size.width - screenBounds.origin.x - screenBounds.size.width - outset;
	if(offset > 0.0f) {
		pixelBounds.size.width -= offset;
	}
	
	[super setPosition:myPosition];
	self.bounds = pixelBounds;
	//RMLog(@"x:%f y:%f screen bounds: %f %f %f %f", myPosition.x, myPosition.y,  screenBounds.origin.x, screenBounds.origin.y, screenBounds.size.width, screenBounds.size.height);
	//RMLog(@"new bounds: %f %f %f %f", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
	
	self.anchorPoint = CGPointMake(-pixelBounds.origin.x / pixelBounds.size.width,-pixelBounds.origin.y / pixelBounds.size.height);
	[self setNeedsDisplay];
}

- (void) addPointToXY: (RMProjectedPoint) point withDrawing: (BOOL)isDrawing
{
	//	RMLog(@"addLineToXY %f %f", point.x, point.y);


	if(isFirstPoint)
	{
		isFirstPoint = FALSE;
		projectedLocation = point;

		self.position = [[contents mercatorToScreenProjection] projectXYPoint: projectedLocation];
		//		RMLog(@"screen position set to %f %f", self.position.x, self.position.y);
		CGPathMoveToPoint(path, NULL, 0.0f, 0.0f);
	}
	else
	{
		point.easting = point.easting - projectedLocation.easting;
		point.northing = point.northing - projectedLocation.northing;

		if (isDrawing)
		{
			CGPathAddLineToPoint(path, NULL, point.easting, -point.northing);
		} else {
			CGPathMoveToPoint(path, NULL, point.easting, -point.northing);
		}

		[self recalculateGeometry];
	}
	[self setNeedsDisplay];
}

- (void) moveToXY: (RMProjectedPoint) point
{
	[self addPointToXY: point withDrawing: FALSE];
}

- (void) moveToScreenPoint: (CGPoint) point
{
	RMProjectedPoint mercator = [[contents mercatorToScreenProjection] projectScreenPointToXY: point];
	
	[self moveToXY: mercator];
}

- (void) moveToLatLong: (RMLatLong) point
{
	RMProjectedPoint mercator = [[contents projection] latLongToPoint:point];
	
	[self moveToXY:mercator];
}

- (void) addLineToXY: (RMProjectedPoint) point
{
	[self addPointToXY: point withDrawing: TRUE];
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
    CGFloat *dashLengths = _lineDashLengths;
	
	float scale = 1.0f / [contents metersPerPixel];
	
	float scaledLineWidth = lineWidth;
	if(!scaleLineWidth) {
		scaledLineWidth *= renderedScale;
	}
	//NSLog(@"line width = %f, content scale = %f", scaledLineWidth, renderedScale);
	
    if(!scaleLineDash && _lineDashLengths) {
        dashLengths = _scaledLineDashLengths;
        for(size_t dashIndex=0; dashIndex<_lineDashCount; dashIndex++){
            dashLengths[dashIndex] = _lineDashLengths[dashIndex]*renderedScale;
        }
    }
    
	CGContextScaleCTM(theContext, scale, scale);
	
	CGContextBeginPath(theContext);
	CGContextAddPath(theContext, path); 
	
	CGContextSetLineWidth(theContext, scaledLineWidth);
	CGContextSetLineCap(theContext, lineCap);
	CGContextSetLineJoin(theContext, lineJoin);	
	CGContextSetStrokeColorWithColor(theContext, [lineColor CGColor]);
	CGContextSetFillColorWithColor(theContext, [fillColor CGColor]);
    if(_lineDashLengths){
        CGContextSetLineDash(theContext, lineDashPhase, dashLengths, _lineDashCount);
    }
	
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

- (CGLineCap) lineCap
{
	return lineCap;
}

- (void) setLineCap: (CGLineCap) newLineCap
{
	lineCap = newLineCap;
	[self setNeedsDisplay];
}

- (CGLineJoin) lineJoin
{
	return lineJoin;
}

- (void) setLineJoin: (CGLineJoin) newLineJoin
{
	lineJoin = newLineJoin;
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

- (NSArray *)lineDashLengths {
    NSMutableArray *lengths = [NSMutableArray arrayWithCapacity:_lineDashCount];
    for(size_t dashIndex=0; dashIndex<_lineDashCount; dashIndex++){
        [lengths addObject:(id)[NSNumber numberWithFloat:_lineDashLengths[dashIndex]]];
    }
    return lengths;
}
- (void) setLineDashLengths:(NSArray *)lengths {
    if(_lineDashLengths){
        free(_lineDashLengths);
        _lineDashLengths = NULL;

    }
    if(_scaledLineDashLengths){
        free(_scaledLineDashLengths);
        _scaledLineDashLengths = NULL;
    }
    _lineDashCount = [lengths count];
    if(!_lineDashCount){
        return;
    }
    _lineDashLengths = calloc(_lineDashCount, sizeof(CGFloat));
    if(!scaleLineDash){
        _scaledLineDashLengths = calloc(_lineDashCount, sizeof(CGFloat));
    }

    NSEnumerator *lengthEnumerator = [lengths objectEnumerator];
    id lenObj;
    size_t dashIndex = 0;
    while ((lenObj = [lengthEnumerator nextObject])) {
        if([lenObj isKindOfClass: [NSNumber class]]){
            _lineDashLengths[dashIndex] = [lenObj floatValue];
        } else {
            _lineDashLengths[dashIndex] = 0.0;
        }
        dashIndex++;
    }
}

- (void)moveBy: (CGSize) delta {
	if(enableDragging){
		[super moveBy:delta];
	}
}

- (void)setPosition:(CGPoint)value
{
	[self recalculateGeometry];
}

@end
