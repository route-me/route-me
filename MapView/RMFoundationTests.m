//
//  RMFoundationTests.m
//  MapView
// 
// Copyright (c) 2008-2011, Route-Me Contributors
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

#import "RMFoundationTests.h"

@implementation RMFoundationTests

- (void)testProjectedRectIntersectsProjectedRect {
	RMProjectedRect r0022 = RMMakeProjectedRect(0.0, 0.0, 2.0, 2.0);
	RMProjectedRect r0123 = RMMakeProjectedRect(0.0, 1.0, 2.0, 2.0);
	RMProjectedRect r0325 = RMMakeProjectedRect(0.0, 3.0, 2.0, 2.0);
	RMProjectedRect r1032 = RMMakeProjectedRect(1.0, 0.0, 2.0, 2.0);
	
	STAssertTrue(RMProjectedRectInterectsProjectedRect(r0123, r1032), nil);
	STAssertTrue(RMProjectedRectInterectsProjectedRect(r1032, r0123), nil);
	STAssertFalse(RMProjectedRectInterectsProjectedRect(r0022, r0325), nil);
	STAssertFalse(RMProjectedRectInterectsProjectedRect(r0325, r0022), nil);
	STAssertTrue(RMProjectedRectInterectsProjectedRect(r0022, r0123), nil);
	STAssertTrue(RMProjectedRectInterectsProjectedRect(r0123, r0022), nil);
}

@end
