//
// RMDBMapSource.h
//
// Copyright (c) 2009, Frank Schroeder, SharpMind GbR
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


#import "RMTileSource.h"
#import "RMProjection.h"
#import "FMDatabase.h"

@interface RMDBMapSource : NSObject<RMTileSource> {
	// tile database
	FMDatabase* db;
	
	// projection
	RMFractalTileProjection *tileProjection;
	
	// supported zoom levels
	float minZoom;
	float maxZoom;
	int tileSideLength;
	
	// coverage area
	CLLocationCoordinate2D topLeft;
	CLLocationCoordinate2D bottomRight;
	CLLocationCoordinate2D center;
}

-(id)initWithPath:(NSString*)path;

-(int)tileSideLength;

-(float) minZoom;
-(float) maxZoom;

-(NSString *)shortName;
-(NSString *)longDescription;
-(NSString *)shortAttribution;
-(NSString *)longAttribution;

- (CLLocationCoordinate2D) topLeftOfCoverage;
- (CLLocationCoordinate2D) bottomRightOfCoverage;
- (CLLocationCoordinate2D) centerOfCoverage;

@end
