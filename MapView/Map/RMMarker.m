//
//  RMMarker.m
//  MapView
//
//  Created by Joseph Gentle on 13/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

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
	
	return self;
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

- (void) addLabel: (UIView*)label
{
	[label retain];
	CALayer *layer = [label layer];
	[self addSublayer:layer];
	//[self insertSublayer:[label layer] above:self];
}

- (void) addTextLabel: (NSString*)text atPosition:(CGPoint)position
{
	NSInteger textWidth = [self getPixelWidthForFont:text font:[UIFont systemFontOfSize:12]];
	NSLog(@"TEXT WIDTH: %d",textWidth);
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(position.x,position.y,textWidth, 20)];
	
	[label setNumberOfLines:1];
	[label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[label setBackgroundColor:[UIColor clearColor]];
	[label setTextColor:[UIColor blackColor]];
	[label setFont:[UIFont systemFontOfSize:12]];
	[label setText:text];
	
	[self addLabel:label];
	[label release];
	
}

- (void) dealloc 
{
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

- (NSInteger) getPixelWidthForFont:(NSString *)aString font:(UIFont *)aFont {
	return [aString sizeWithFont:aFont].width;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//	NSLog(@"marker at %f %f m %f %f touchesEnded", self.position.x, self.position.y, location.x, location.y);
}

@end
