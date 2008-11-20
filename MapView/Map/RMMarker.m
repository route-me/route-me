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
@synthesize label;

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
	label = nil;
	
	return self;
}

- (void) replaceImage:(CGImageRef)image anchorPoint:(CGPoint)_anchorPoint
{
	self.contents = (id)image;
	self.bounds = CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image));
	self.anchorPoint = _anchorPoint;
	
	self.masksToBounds = NO;
	label = nil;	
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

- (void) setLabel: (UILabel*)aLabel
{
	if (label != nil)
	{
		[[label layer] removeFromSuperlayer];
		[label release];
	}
	
	if (aLabel != nil)
	{	
		label = [aLabel retain];
		//[self addSublayer:[label layer]];
		[self addSublayer:[label layer]];
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
	
	frame.size = [text sizeWithFont:[UIFont systemFontOfSize:15]];
	
	UILabel *aLabel = [[UILabel alloc] initWithFrame:frame];
	//	UITextField *aLabel = [[UITextField alloc] initWithFrame:frame];
	//	[aLabel setBorderStyle:UITextBorderStyleRoundedRect];
	//	[aLabel setNumberOfLines:1];
	[aLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[aLabel setBackgroundColor:[UIColor clearColor]];
	[aLabel setTextColor:[UIColor blackColor]];
	[aLabel setFont:[UIFont systemFontOfSize:15]];
	[aLabel setTextAlignment:UITextAlignmentCenter];
	[aLabel setText:text];
	//	[aLabel setCenter:CGPointMake(,0)];
	
	[self setLabel:aLabel];
	[aLabel release];
	
}

- (void) toggleLabel
{
	if (label == nil) {
		return;
	}
	
	if ([label isHidden]) {
		[self showLabel];
	} else {
		[self hideLabel];
	}
}

- (void) showLabel
{
	if ([label isHidden]) {
		// Using addSublayer will animate showing the label, whereas setHidden is not animated
		[self addSublayer:[label layer]];
		[label setHidden:NO];
	}
}

- (void) hideLabel
{
	if (![label isHidden]) {
		// Using removeFromSuperlayer will animate hiding the label, whereas setHidden is not animated
		[[label layer] removeFromSuperlayer];
		[label setHidden:YES];
	}
}

- (void) dealloc 
{
	[label release];
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

/*- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//	[label setAlpha:1.0f - [label alpha]];
//	[self setTextLabel:@"hello there"];
	//	NSLog(@"marker at %f %f m %f %f touchesEnded", self.position.x, self.position.y, location.x, location.y);
}*/

@end
