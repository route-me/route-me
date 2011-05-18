//
//  RMMapLayer.m
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

#import "RMMapLayer.h"
#import "RMPixel.h"

@implementation RMMapLayer

- (id) init
{
	if (![super init])
		return nil;
	
	return self;
}

- (id)initWithLayer:(id)layer
{
	if (![super initWithLayer:layer])
		return nil;
	
	return self;
}

/// \bug why return nil for the "position" and "bounds" actionForKey? Does this do anything besides block Core Animation?
- (id<CAAction>)actionForKey:(NSString *)key
{
	if ([key isEqualToString:@"position"]
		|| [key isEqualToString:@"bounds"])
		return nil;
	
	else return [super actionForKey:key];
}

- (void)moveBy: (CGSize) delta
{
	self.position = RMTranslateCGPointBy(self.position, delta);
}

- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) pivot
{
    // a empty layer has size=(0,0) which cause divide by 0 if scaled
    if(self.bounds.size.width == 0.0 || self.bounds.size.height == 0.0)
        return;
	self.position = RMScaleCGPointAboutPoint(self.position, zoomFactor, pivot);
	self.bounds = RMScaleCGRectAboutPoint(self.bounds, zoomFactor, self.anchorPoint);
}

@end
