//
//  RMMapRenderer.m
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

#import "RMMapRenderer.h"

#import "RMTileImage.h"

@implementation RMMapRenderer

// Designated initialiser
- (id) initWithContent: (RMMapContents *)_contents
{
	if (![super init])
		return nil;

	content = _contents;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapImageLoaded:) name:RMMapImageLoadedNotification object:nil];
	
	return self;
}

-(void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

/// \bug no-op
- (void) setNeedsDisplay
{
	
}

/// \bug calls a no-op
-(void)mapImageLoaded: (NSNotification*)notification
{
	[self setNeedsDisplay];
}

/// \bug no-op
- (void)drawRect:(CGRect)rect
{ }

/// \bug no-op
- (void)setFrame:(CGRect)frame
{
}


/// \bug no-op
- (CALayer*) layer
{
	return nil;
}



@end
