//
//  RMMarker.h
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

#import <UIKit/UIKit.h>
#import "RMMapLayer.h"
#import "RMFoundation.h"
#ifdef DEBUG
#import <CoreLocation/CoreLocation.h>
#endif

@class RMMarkerStyle;

/// one marker drawn on the map. Note that RMMarker ultimately descends from CALayer, and has an image contents.
/// RMMarker inherits "position" and "anchorPoint" from CALayer.
@interface RMMarker : RMMapLayer <RMMovingMapLayer> {
	/// expressed in projected meters. The anchorPoint of the image is plotted here. 
	RMProjectedPoint projectedLocation;	
	/// provided for storage of arbitrary user data
	NSObject* data; 
	
	/// Text label, visible by default if it has content, but not required.
	UIView *label;
	UIColor *textForegroundColor;
	UIColor *textBackgroundColor;
	
	BOOL enableDragging;
	BOOL enableRotation;
}
@property (assign, nonatomic) RMProjectedPoint projectedLocation;
@property (assign) BOOL enableDragging;
@property (assign) BOOL enableRotation;

@property (nonatomic, retain) NSObject* data;
@property (nonatomic, retain) UIView* label;
@property(nonatomic,retain) UIColor *textForegroundColor;
@property(nonatomic,retain) UIColor *textBackgroundColor;

/// the font used for labels when another font is not explicitly requested; currently [UIFont systemFontOfSize:15]
+ (UIFont *)defaultFont;

/// returns RMMarker initialized with #image, and the default anchor point (0.5, 0.5)
- (id) initWithUIImage: (UIImage*) image;
/// \brief returns RMMarker initialized with provided image and anchorPoint. 
/// #anchorPoint x and y range from 0 to 1, normalized to the width and height of image, 
/// referenced to upper left corner, y increasing top to bottom. To put the image's upper right corner on the marker's 
/// #projectedLocation, use an anchor point of (1.0, 0.0);
- (id) initWithUIImage: (UIImage*) image anchorPoint: (CGPoint) anchorPoint;

/// changes the labelView to a UILabel with supplied #text and default marker font, using existing text foreground/background color.
- (void) changeLabelUsingText: (NSString*)text;
/// changes the labelView to a UILabel with supplied #text and default marker font, positioning the text some weird way i don't understand yet. Uses existing text color/background color.
- (void) changeLabelUsingText: (NSString*)text position:(CGPoint)position;
/// changes the labelView to a UILabel with supplied #text and default marker font, changing this marker's text foreground/background colors for this and future text strings.
- (void) changeLabelUsingText: (NSString*)text font:(UIFont*)font foregroundColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor;
/// changes the labelView to a UILabel with supplied #text and default marker font, changing this marker's text foreground/background colors for this and future text strings; modifies position as in #changeLabelUsingText:position.
- (void) changeLabelUsingText: (NSString*)text position:(CGPoint)position font:(UIFont*)font foregroundColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor;

- (void) toggleLabel;
- (void) showLabel;
- (void) hideLabel;

- (void) replaceUIImage:(UIImage*)image;
- (void) replaceUIImage:(UIImage*)image anchorPoint:(CGPoint)anchorPoint;


- (void) dealloc;

@end
