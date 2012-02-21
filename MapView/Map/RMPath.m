///
//  RMPath.m
//
// Copyright (c) 2008-2010, Route-Me Contributors
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

@interface RMPath ()
- (void)addPointToXY:(RMProjectedPoint) point withDrawing:(BOOL)isDrawing;
- (void)recalculateGeometry;
@end

@implementation RMPath
@synthesize lineWidth, lineColor, fillColor, scaleLineWidth, lineDashPhase, lineDashLengths, scaleLineDash, projectedLocation, enableDragging, enableRotation;
@dynamic CGPath, projectedBounds;

- (id) initWithContents: (RMMapContents*)aContents {
	if (![super init]) return nil;
	
	contents = aContents;
    
	path = CGPathCreateMutable();
	
    // Defaults
	lineWidth = 4.0;
	scaleLineWidth = NO;
	enableDragging = YES;
	enableRotation = YES;
    self.lineColor = [UIColor blackColor];
    scaleLineDash = NO;
	_lineDashCount = 0;
    _lineDashLengths = NULL;
    _scaledLineDashLengths = NULL;
    lineDashPhase = 0.0;
    
    self.masksToBounds = YES;
    
    if ( [self respondsToSelector:@selector(setContentsScale:)] ) self.contentsScale = ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [UIScreen mainScreen].scale : 1.0);
    
	return self;
}

- (id) initForMap: (RMMapView*)map {
	return [self initWithContents:[map contents]];
}

- (id) initForMap: (RMMapView*)map withCoordinates:(const CLLocationCoordinate2D*)coordinates count:(NSInteger)count {
    if ( !(self = [self initWithContents:[map contents]]) ) return nil;
    
    [self moveToLatLong:coordinates[0]];
    for ( NSInteger i=1; i<count; i++ ) {
        [self addLineToLatLong:coordinates[i]];
    }
    
    return self;
}

-(void) dealloc {
	CGPathRelease(path);
    self.lineColor = nil;
    self.fillColor = nil;
	[super dealloc];
}

- (id<CAAction>)actionForKey:(NSString *)key {
	return nil;
}

- (void) moveToXY: (RMProjectedPoint) point {
	[self addPointToXY: point withDrawing: FALSE];
}

- (void) moveToScreenPoint: (CGPoint) point {
	[self moveToXY: [[contents mercatorToScreenProjection] projectScreenPointToXY: point]];
}

- (void) moveToLatLong: (RMLatLong) point {
	[self moveToXY:[[contents projection] latLongToPoint:point]];
}

- (void) addLineToXY: (RMProjectedPoint) point {
	[self addPointToXY: point withDrawing: TRUE];
}

- (void) addLineToScreenPoint: (CGPoint) point {
	[self addLineToXY: [[contents mercatorToScreenProjection] projectScreenPointToXY: point]];
}

- (void) addLineToLatLong: (RMLatLong) point{
	[self addLineToXY:[[contents projection] latLongToPoint:point]];
}

- (void) closePath {
	CGPathCloseSubpath(path);
}

- (void) setLineWidth: (float) newLineWidth {
	lineWidth = newLineWidth;
	[self recalculateGeometry];
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

- (void)setLineColor:(UIColor *)aLineColor {
    if (lineColor != aLineColor) {
        [lineColor release];
        lineColor = [aLineColor retain];
		[self setNeedsDisplay];
    }
}

- (void)setFillColor:(UIColor *)aFillColor {
    if (fillColor != aFillColor) {
        [fillColor release];
        fillColor = [aFillColor retain];
		[self setNeedsDisplay];
    }
}

- (void)moveBy: (CGSize) delta {
	if(enableDragging){
		[super moveBy:delta];
	}
}

- (void)setPosition:(CGPoint)value {
    [super setPosition:value];
	[self recalculateGeometry];
}

- (void)addPointToXY:(RMProjectedPoint) point withDrawing:(BOOL)isDrawing {
	if ( CGPathIsEmpty(path) ) {
		projectedLocation = point;
		self.position = [[contents mercatorToScreenProjection] projectXYPoint:projectedLocation];
		CGPathMoveToPoint(path, NULL, 0.0f, 0.0f);
	} else {
		point.easting = point.easting - projectedLocation.easting;
		point.northing = point.northing - projectedLocation.northing;
		if ( isDrawing ) {
			CGPathAddLineToPoint(path, NULL, point.easting, point.northing);
		} else {
			CGPathMoveToPoint(path, NULL, point.easting, point.northing);
		}
        
		[self recalculateGeometry];
	}
	[self setNeedsDisplay];
}

- (void)recalculateGeometry {
	RMMercatorToScreenProjection *projection = [contents mercatorToScreenProjection];
	const float outset = 100.0f;
	
	float scaledLineWidth = lineWidth;
	if ( !scaleLineWidth ) {
		scaledLineWidth *= [contents metersPerPixel];
	}
	
    // Get path dimensions (in mercators relative to projectedLocation; bounding box origin is bottom-left due to flipped coord system)
	CGRect pathDimensions = CGRectInset(CGPathGetBoundingBox(path), -scaledLineWidth, -scaledLineWidth);
    
    // Convert bounding box to pixels in Quartz coord space, relative to projectedLocation in Quartz coord space
    CGRect pixelBounds = RMScaleCGRectAboutPoint(CGRectMake(pathDimensions.origin.x, 
                                                            -pathDimensions.origin.y - pathDimensions.size.height, 
                                                            pathDimensions.size.width, 
                                                            pathDimensions.size.height),
                                                 1.0f / [projection metersPerPixel], CGPointZero);
    
	// Clip bound rect to screen bounds.
	// If bounds are not clipped, they won't display when you zoom in too much.
	CGPoint myPosition = [projection projectXYPoint: projectedLocation];
	CGRect screenBounds = [contents screenBounds];
    pixelBounds.origin.x += myPosition.x; pixelBounds.origin.y += myPosition.y;
    pixelBounds = CGRectIntersection(pixelBounds, CGRectInset(screenBounds, -outset, -outset));
    
    if (!CGRectIsNull(pixelBounds)) {
        pixelBounds.origin.x -= myPosition.x; pixelBounds.origin.y -= myPosition.y;
        self.anchorPoint = CGPointMake(-pixelBounds.origin.x / pixelBounds.size.width,-pixelBounds.origin.y / pixelBounds.size.height);
    }
    
    self.bounds = pixelBounds;
    
    [super setPosition:myPosition];
    
    [self setNeedsDisplay];
}

- (void)drawInContext:(CGContextRef)theContext {
	float scale = 1.0f / [contents metersPerPixel];
	
	float scaledLineWidth = lineWidth;
	if ( !scaleLineWidth ) {
		scaledLineWidth *= [contents metersPerPixel];
	}
	
    CGFloat *dashLengths = _lineDashLengths;
    if(!scaleLineDash && _lineDashLengths) {
        dashLengths = _scaledLineDashLengths;
        for(size_t dashIndex=0; dashIndex<_lineDashCount; dashIndex++){
            dashLengths[dashIndex] = _lineDashLengths[dashIndex] * scale;
        }
    }
    
	CGContextScaleCTM(theContext, scale, -scale); // Flip vertically, as path is in projected coord space with origin with y axis increasing upwards
	
	CGContextBeginPath(theContext);
	CGContextAddPath(theContext, path); 
	
	CGContextSetLineWidth(theContext, scaledLineWidth);
	CGContextSetLineCap(theContext, kCGLineCapRound);
	CGContextSetLineJoin(theContext, kCGLineJoinRound);	
    if(_lineDashLengths){
        CGContextSetLineDash(theContext, lineDashPhase, dashLengths, _lineDashCount);
    }
    
    if ( lineColor ) {
        CGContextSetStrokeColorWithColor(theContext, [lineColor CGColor]);
    }
    
    if ( fillColor ) {
        CGContextSetFillColorWithColor(theContext, [fillColor CGColor]);
    }
	
	CGContextDrawPath(theContext, (lineColor && fillColor ? kCGPathFillStroke : (lineColor ? kCGPathStroke : kCGPathFill)));
}

- (CGPathRef)CGPath {
    return path;
}

- (RMProjectedRect)projectedBounds {
    float scaledLineWidth = lineWidth;
	if ( !scaleLineWidth ) {
		scaledLineWidth *= [contents metersPerPixel];
	}
    CGRect regionRect = CGRectInset(CGPathGetBoundingBox(path), -scaledLineWidth, -scaledLineWidth);
    return RMMakeProjectedRect(regionRect.origin.x + projectedLocation.easting,
                               regionRect.origin.y + projectedLocation.northing,
                               regionRect.size.width, 
                               regionRect.size.height);
}

@end