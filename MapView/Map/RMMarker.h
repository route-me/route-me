//
//  RMMarker.h
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

#import <UIKit/UIKit.h>
#import "RMMapLayer.h"
#import "RMFoundation.h"

@class RMMarkerStyle;

extern NSString * const RMMarkerBlueKey;
extern NSString * const RMMarkerRedKey;

@interface RMMarker : RMMapLayer <RMMovingMapLayer> {
	RMXYPoint location;	

	NSObject* data; // provided for storage of arbitrary user data
	
	// A label which comes up when you tap the marker
	UIView *labelView;
	UIColor *textForegroundColor;
	UIColor *textBackgroundColor;
}
@property (assign, nonatomic) RMXYPoint location;
@property (nonatomic, retain) NSObject* data;
@property (nonatomic, retain) UIView* labelView;
@property(nonatomic,retain) UIColor *textForegroundColor;
@property(nonatomic,retain) UIColor *textBackgroundColor;

/// \deprecated Deprecated at any moment after 0.5.
+ (RMMarker*) markerWithNamedStyle: (NSString*) styleName;
/// \deprecated Deprecated at any moment after 0.5.
+ (CGImageRef) markerImage: (NSString *) key;
/// \deprecated Deprecated at any moment after 0.5.
+ (CGImageRef) loadPNGFromBundle: (NSString *)filename;

- (id) initWithCGImage: (CGImageRef) image anchorPoint: (CGPoint) anchorPoint;
- (id) initWithCGImage: (CGImageRef) image;
/// \deprecated Deprecated at any moment after 0.5. Use initWithUIImage:.
- (id) initWithKey: (NSString*) key;
- (id) initWithUIImage: (UIImage*) image;
/// \deprecated Deprecated at any moment after 0.5. Use initWithUIImage:.
- (id) initWithStyle: (RMMarkerStyle*) style;
/// \deprecated Deprecated at any moment after 0.5. Use initWithUIImage:.
- (id) initWithNamedStyle: (NSString*) styleName;

- (void) setLabel: (UIView*)aView;
- (void) setTextLabel: (NSString*)text;
- (void) setTextLabel: (NSString*)text toPosition:(CGPoint)position;
- (void) setTextLabel: (NSString*)text withFont:(UIFont*)font withTextColor:(UIColor*)textColor withBackgroundColor:(UIColor*)backgroundColor;
- (void) setTextLabel: (NSString*)text toPosition:(CGPoint)position withFont:(UIFont*)font withTextColor:(UIColor*)textColor withBackgroundColor:(UIColor*)backgroundColor;
- (void) toggleLabel;
- (void) showLabel;
- (void) hideLabel;
- (void) removeLabel;

- (void) replaceImage:(CGImageRef)image anchorPoint:(CGPoint)_anchorPoint;
/// \deprecated Deprecated at any moment after 0.5.
- (void) replaceKey: (NSString*) key;

/// \deprecated Deprecated at any moment after 0.4.
- (void) hide;
/// \deprecated Deprecated at any moment after 0.4.
- (void) unhide;

- (void) dealloc;

// Call this with either RMMarkerBlue or RMMarkerRed for the key.
/// \deprecated Deprecated at any moment after 0.5.
+ (CGImageRef) markerImage: (NSString *) key;

@end
