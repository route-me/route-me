//
//  RMCountedSet.m
//
// Copyright (c) 2010, Route-Me Contributors
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

#import "RMCountedSet.h"

// Workaround for changed behavior of NSCountedSet in os4.0 beta1&2
// it used to always retain the first object added
// new behavior is to replace that object with the one passed into
// addObject: and removeObject:
// this is a problem for us because of the dummy tiles being added/removed
// that don't actually contain the same data as the real tile objects
// even though isEqual: will return true.

@implementation RMCountedSet

-(void)addObject:(id)object
{
  id objectToAdd = [self member:object];
  if ( ! objectToAdd )
    objectToAdd = object;
  [super addObject:objectToAdd];
}

-(void)removeObject:(id)object
{
  id objectToRemove = [self member:object];
  if ( ! objectToRemove )
    return;
  [super removeObject:objectToRemove];
}


@end
