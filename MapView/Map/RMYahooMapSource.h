//
//  RMYahooMapSouce.h
//  MapView
//
// Copyright (c) 2008-2009, Yahoo
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

#import "RMAbstractMercatorWebSource.h"

// This code is an example.  Using it is a bad idea.  It likely violates
// all Yahoo terms of service.  All of them.  But it IS a good functioning
// example.  If you ship code using this, yahoo might be very angry, and come
// at you with pitchforks.  Maybe.

/*! 
 \brief RMAbstractMercatorWebSource subclass for access to Yahoo! Maps. Demo only; not for use in shipping apps.
 
 Provides key-based access to tiles from Yahoo! Maps. Do not ship applications using this tile source, as 
 Route-Me's implementation violates the Yahoo! Maps terms of service.
 */
@interface RMYahooMapSource : RMAbstractMercatorWebSource <RMAbstractMercatorWebSource>
{

}

@end
