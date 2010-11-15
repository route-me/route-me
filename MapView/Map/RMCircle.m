///
//  RMCircle.m
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

#import "RMCircle.h"
#import "RMMapContents.h"
#import "RMProjection.h"
#import "RMMercatorToScreenProjection.h"

#define kDefaultLineWidth 10
#define kDefaultLineColor [UIColor blackColor]
#define kDefaultFillColor [UIColor blueColor]

@interface RMCircle ()

- (void)updateCirclePath;

@end


@implementation RMCircle

@synthesize shapeLayer;
@synthesize projectedLocation;
@synthesize enableDragging;
@synthesize enableRotation;
@synthesize lineColor;
@synthesize fillColor;
@synthesize radiusInMeters;
@synthesize lineWidthInPixels;

- (id)initWithContents:(RMMapContents*)aContents radiusInMeters:(CGFloat)newRadiusInMeters latLong:(RMLatLong)newLatLong {
	self = [super init];
	
	if (self) {
		CAShapeLayer* newShapeLayer = [[CAShapeLayer alloc] init];
		shapeLayer = newShapeLayer;
		[self addSublayer:newShapeLayer];
		
		mapContents = aContents;
		radiusInMeters = newRadiusInMeters;
		latLong = newLatLong;
		projectedLocation = [[mapContents projection] latLongToPoint:newLatLong];
		[self setPosition:[[mapContents mercatorToScreenProjection] projectXYPoint:projectedLocation]];
//		DLog(@"Position: %f, %f", [self position].x, [self position].y);
		
		lineWidthInPixels = kDefaultLineWidth;
		lineColor = kDefaultLineColor;
		fillColor = kDefaultFillColor;
		
		scaleLineWidth = NO;
		enableDragging = YES;
		enableRotation = YES;
		
		circlePath = NULL;
		[self updateCirclePath];
	}
	
	return self;
}

- (void)dealloc {
	[shapeLayer release];
	shapeLayer = nil;
	CGPathRelease(circlePath);
	[lineColor release];
	lineColor = nil;
	[fillColor release];
	fillColor = nil;
	[super dealloc];
}

#pragma mark -

- (void)updateCirclePath {
	CGPathRelease(circlePath);
	
	CGMutablePathRef newPath = CGPathCreateMutable();
	
	CGFloat latRadians = latLong.latitude * M_PI / 180.0f;
	CGFloat pixelRadius = radiusInMeters / cos(latRadians) / [mapContents metersPerPixel];
//	DLog(@"Pixel Radius: %f", pixelRadius);
	
	CGRect rectangle = CGRectMake(self.position.x - pixelRadius, 
								  self.position.y - pixelRadius, 
								  (pixelRadius * 2), 
								  (pixelRadius * 2));
	
	CGFloat offset = floorf(-lineWidthInPixels / 2.0f) - 2;
//	DLog(@"Offset: %f", offset);
	CGRect newBoundsRect = CGRectInset(rectangle, offset, offset);
	[self setBounds:newBoundsRect];
	
//	DLog(@"Circle Rectangle: %f, %f, %f, %f", rectangle.origin.x, rectangle.origin.y, rectangle.size.width, rectangle.size.height);
//	DLog(@"Bounds Rectangle: %f, %f, %f, %f", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
	
	CGPathAddEllipseInRect(newPath, NULL, rectangle);
	circlePath = newPath;
	
	[[self shapeLayer] setPath:newPath];
	[[self shapeLayer] setFillColor:[fillColor CGColor]];
	[[self shapeLayer] setStrokeColor:[lineColor CGColor]];
	[[self shapeLayer] setLineWidth:lineWidthInPixels];
}

#pragma mark Accessors

- (void)setProjectedLocation:(RMProjectedPoint)newProjectedLocation {
	projectedLocation = newProjectedLocation;
	
	[self setPosition:[[mapContents mercatorToScreenProjection] projectXYPoint:projectedLocation]];
}

- (void)setLineColor:(UIColor*)newLineColor {
	if (lineColor != newLineColor) {
		[lineColor release];
		lineColor = [newLineColor retain];
		[self updateCirclePath];
	}
}

- (void)setFillColor:(UIColor*)newFillColor {
	if (fillColor != newFillColor) {
		[fillColor release];
		fillColor = [newFillColor retain];
		[self updateCirclePath];
	}
}

- (void)setRadiusInMeters:(CGFloat)newRadiusInMeters {
	radiusInMeters = newRadiusInMeters;
	[self updateCirclePath];
}

- (void)setLineWidthInPixels:(CGFloat)newLineWidthInPixels {
	lineWidthInPixels = newLineWidthInPixels;
	[self updateCirclePath];
}

#pragma mark Map Movement and Scaling

- (void)moveBy:(CGSize)delta {
	if (enableDragging) {
		[super moveBy:delta];
	}
}

- (void)zoomByFactor:(float)zoomFactor near:(CGPoint)center {
	[super zoomByFactor:zoomFactor near:center];
	
	[self updateCirclePath];
}

- (void)moveToLatLong:(RMLatLong)newLatLong {
	latLong = newLatLong;
	[self setProjectedLocation:[[mapContents projection] latLongToPoint:newLatLong]];
	[self setPosition:[[mapContents mercatorToScreenProjection] projectXYPoint:projectedLocation]];
//	DLog(@"Position: %f, %f", [self position].x, [self position].y);
}

@end
