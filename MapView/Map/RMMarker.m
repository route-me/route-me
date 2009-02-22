//
//  RMMarker.m
//
// Copyright (c) 2008, Route-Me Contributors
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

#import "RMMarker.h"
#import "RMMarkerStyle.h"
#import "RMMarkerStyles.h"

#import "RMPixel.h"

NSString* const RMMarkerBlueKey = @"RMMarkerBlueKey";
NSString* const RMMarkerRedKey = @"RMMarkerRedKey";

static CGImageRef _markerRed = nil;
static CGImageRef _markerBlue = nil;

@implementation RMMarker

@synthesize location;
@synthesize data;
@synthesize labelView;

+ (RMMarker*) markerWithNamedStyle: (NSString*) styleName
{
	return [[[RMMarker alloc] initWithNamedStyle: styleName] autorelease];
}

- (id) initWithCGImage: (CGImageRef) image
{
	return [self initWithCGImage: image anchorPoint: CGPointMake(0.5, 1.0)];
}

- (id) initWithCGImage: (CGImageRef) image anchorPoint: (CGPoint) _anchorPoint
{
	if (![super init])
		return nil;
	
	self.contents = (id)image;
	self.bounds = CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image));
	self.anchorPoint = _anchorPoint;
	
	self.masksToBounds = NO;
	labelView = nil;
	
	return self;
}

- (void) replaceImage:(CGImageRef)image anchorPoint:(CGPoint)_anchorPoint
{
	self.contents = (id)image;
	self.bounds = CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image));
	self.anchorPoint = _anchorPoint;
	
	self.masksToBounds = NO;
	labelView = nil;	
}

- (id) initWithUIImage: (UIImage*) image
{
	return [self initWithCGImage: [image CGImage]];
}

- (id) initWithKey: (NSString*) key
{
	return [self initWithCGImage:[RMMarker markerImage:key]];
}

- (id) initWithStyle: (RMMarkerStyle*) style
{
	return [self initWithCGImage: [style.markerIcon CGImage] anchorPoint: style.anchorPoint]; 
}

- (id) initWithNamedStyle: (NSString*) styleName
{
	RMMarkerStyle* style = [[RMMarkerStyles styles] styleNamed: styleName];
	
	if (style==nil) {
		NSLog(@"problem creating marker: style '%@' not found", styleName);
		return [self initWithCGImage: [RMMarker markerImage: RMMarkerRedKey]];
	}
	return [self initWithStyle: style];
}

- (void) setLabel: (UIView*)aView
{
	if (labelView == aView) {
		return;
	}

	if (labelView != nil)
	{
		[[labelView layer] removeFromSuperlayer];
		[labelView release];
		labelView = nil;
	}
	
	if (aView != nil)
	{
		labelView = [aView retain];
		[self addSublayer:[labelView layer]];
	}
}


- (void) setTextLabel: (NSString*)text
{
	[self setTextLabel:text toPosition:CGPointMake([self bounds].size.width / 2 - [text sizeWithFont:[UIFont systemFontOfSize:15]].width / 2, 4)];;	
}

- (void) setTextLabel: (NSString*)text toPosition:(CGPoint)position
{
	CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:15]];
	CGRect frame = CGRectMake(position.x,
							  position.y,
							  textSize.width+4,
							  textSize.height+4);
	
	UILabel *aLabel = [[UILabel alloc] initWithFrame:frame];
	[aLabel setNumberOfLines:0];
	[aLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[aLabel setBackgroundColor:[UIColor clearColor]];
	[aLabel setTextColor:[UIColor blackColor]];
	[aLabel setFont:[UIFont systemFontOfSize:15]];
	[aLabel setTextAlignment:UITextAlignmentCenter];
	[aLabel setText:text];
	
	[self setLabel:aLabel];
	[aLabel release];
	
}

- (void) removeLabel
{
	if (labelView != nil)
	{
		[[labelView layer] removeFromSuperlayer];
		[labelView release];
		labelView = nil;
	}

}
		
- (void) toggleLabel
{
	if (labelView == nil) {
		return;
	}
	
	if ([labelView isHidden]) {
		[self showLabel];
	} else {
		[self hideLabel];
	}
}

- (void) showLabel
{
	if ([labelView isHidden]) {
		// Using addSublayer will animate showing the label, whereas setHidden is not animated
		[self addSublayer:[labelView layer]];
		[labelView setHidden:NO];
	}
}

- (void) hideLabel
{
	if (![labelView isHidden]) {
		// Using removeFromSuperlayer will animate hiding the label, whereas setHidden is not animated
		[[labelView layer] removeFromSuperlayer];
		[labelView setHidden:YES];
	}
}

- (void) dealloc 
{
	[labelView release];
	[data release];
	[super dealloc];
}

- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center
{
	self.position = RMScaleCGPointAboutPoint(self.position, zoomFactor, center);
	
/*	CGRect currentRect = CGRectMake(self.position.x, self.position.y, self.bounds.size.width, self.bounds.size.height);
	CGRect newRect = RMScaleCGRectAboutPoint(currentRect, zoomFactor, center);
	self.position = newRect.origin;
	self.bounds = CGRectMake(0, 0, newRect.size.width, newRect.size.height);
*/
}

+ (CGImageRef) loadPNGFromBundle: (NSString *)filename
{
	NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"png"];
	CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename([path UTF8String]);
	CGImageRef image = CGImageCreateWithPNGDataProvider(dataProvider, NULL, FALSE, kCGRenderingIntentDefault);
	[NSMakeCollectable(image) autorelease];
	CGDataProviderRelease(dataProvider);
	
	return image;
}

+ (CGImageRef) markerImage: (NSString *) key
{
	if (RMMarkerBlueKey == key
		|| [RMMarkerBlueKey isEqualToString:key])
	{
		if (_markerBlue == nil)
			_markerBlue = [self loadPNGFromBundle:@"marker-blue"];
		
		return _markerBlue;
	}
	else if (RMMarkerRedKey == key
		|| [RMMarkerRedKey isEqualToString: key])
	{
		if (_markerRed == nil)
			_markerRed = [self loadPNGFromBundle:@"marker-red"];
		
		return _markerRed;
	}
	
	return nil;
}

- (void) hide 
{
	[self setHidden:YES];
}

- (void) unhide
{
	[self setHidden:NO];
}


/*- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//	[label setAlpha:1.0f - [label alpha]];
//	[self setTextLabel:@"hello there"];
	//	NSLog(@"marker at %f %f m %f %f touchesEnded", self.position.x, self.position.y, location.x, location.y);
}*/

@end
