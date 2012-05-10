//
//  RMURLConnectionOperation.m
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

#import "RMURLConnectionOperation.h"

@interface RMURLConnectionOperation () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property(retain) NSURLConnection *connection;
@property(retain) NSPort* port;

@property BOOL executing;
@property BOOL finished;

- (void)completeOperation;

@end

@implementation RMURLConnectionOperation 
@synthesize connection = _connection;
@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize port = _port;

- (id)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate
{
    self = [super init];
    if (self) {
        _connection = [[NSURLConnection alloc] initWithRequest:request delegate:delegate startImmediately:NO];
        self.port = [NSPort port];
    }
    return self;
}

- (void)dealloc {
    
    [_connection cancel];
    [_connection release];
    
    [[NSRunLoop mainRunLoop] removePort:self.port forMode:NSDefaultRunLoopMode];
    [_port release];
    
    [super dealloc];
}

#pragma mark - overridden NSOperation methods

- (void)start
{
    // Always check for cancellation before launching the task.
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        
        self.finished = YES;
        
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    
    //the magical run loop trick will force NSURLConnection to call the delegate methods on main thread 
    [[NSRunLoop mainRunLoop] addPort:self.port forMode:NSDefaultRunLoopMode];
    [_connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.connection start];
    [[NSRunLoop mainRunLoop] run];

    self.executing = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return self.executing;
}

- (BOOL)isFinished
{
    return self.finished;
}

- (void)cancel
{
    [super cancel];
    
    if ([self isExecuting]) {
        [self.connection cancel];
        [self completeOperation];
    }
}

#pragma mark - private methods

- (void)completeOperation 
{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    self.executing = NO;
    self.finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end
