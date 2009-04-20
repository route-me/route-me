//
//  RMGeoHash.m
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

#import "RMGeoHash.h"

static NSString *BASE32 = @"0123456789bcdefghjkmnpqrstuvwxyz";

static NSString *NEIGHBORS[4][2] = 
{ { @"bc01fg45238967deuvhjyznpkmstqrwx",@"p0r21436x8zb9dcf5h7kjnmqesgutwvy" },	// right
{ @"238967debc01fg45kmstqrwxuvhjyznp",@"14365h7k9dcfesgujnmqp0r2twvyx8zb" },	// left
{ @"p0r21436x8zb9dcf5h7kjnmqesgutwvy",@"bc01fg45238967deuvhjyznpkmstqrwx" },	// top
{ @"14365h7k9dcfesgujnmqp0r2twvyx8zb",@"238967debc01fg45kmstqrwxuvhjyznp" } };	// bottom

static NSString *BORDERS[4][2] = 
{ { @"bcfguvyz",@"prxz" },	// right
{ @"0145hjnp", @"028b" },	// left
{ @"prxz",@"bcfguvyz" },	// top
{ @"028b", @"0145hjnp" } };	// bottom

@implementation RMGeoHash

+ (NSString *) fromLocation: (CLLocationCoordinate2D) loc withPrecision: (NSInteger)precision 
{	
	BOOL is_even = TRUE;
	int bit=0, ch=0;
	NSMutableString *geohash = [[[NSMutableString string] retain] autorelease];
	
	CLLocationCoordinate2D loc1 = { -90.0, -180.0 };
	CLLocationCoordinate2D loc2 = { 90.0, 180.0 };
	CLLocationDegrees mid;
	
	int hashLen = 0;
	while (hashLen < precision) {
		if (is_even) {
			mid = (loc1.longitude + loc2.longitude) / 2;
			if (loc.longitude > mid) {
				ch |= 1<<(4-bit);
				loc1.longitude = mid;
			} else
				loc2.longitude = mid;
		} else {
			mid = (loc1.latitude + loc2.latitude) / 2;
			if (loc.latitude > mid) {
				ch |= 1<<(4-bit);
				loc1.latitude = mid;
			} else
				loc2.latitude = mid;
		}
		is_even = !is_even;
		if (bit < 4)
			bit++;
		else {
			[geohash appendString: [BASE32 substringWithRange:NSMakeRange(ch, 1)]];
			hashLen++;
			bit = 0;
			ch = 0;
		}
	}
	return geohash;
}

+ (void) convert: (NSString *)geohash toMin: (CLLocationCoordinate2D *)loc1 max: (CLLocationCoordinate2D *)loc2 
{
	BOOL is_even = TRUE;	
	loc1->latitude  =  -90.0;
	loc1->longitude = -180.0;
	loc2->latitude = 90.0;
	loc2->longitude = 180.0;
	NSRange	range;
	int cd, mask;
	int geohashLen = [geohash length];
	for (int i=0; i<geohashLen; i++) {
		range = [BASE32 rangeOfString: [geohash substringWithRange:NSMakeRange(i, 1)]];
		cd = range.location;		
		for (int j=0; j<5; j++) {
			mask = 1<<(4-j);
			if (is_even) {
				if(cd&mask){
					loc1->longitude = (loc1->longitude + loc2->longitude)/2;
				} else {
					loc2->longitude = (loc1->longitude + loc2->longitude)/2;
				}
			} else {
				if(cd&mask){
					loc1->latitude = (loc1->latitude + loc2->latitude)/2;
				} else {
					loc2->latitude = (loc1->latitude + loc2->latitude)/2;
				}
			}
			is_even = !is_even;
		}
	}
}

+ (NSString *) adjacentOf: (NSString *)srcHash inDir: (RMGeoHashAtDirection) dir 
{
	int srcHashLen = [srcHash length];
	NSString *lastChr = [srcHash substringFromIndex: srcHashLen - 1];
	int type = srcHashLen & 0x1;
	NSString *base = [srcHash substringToIndex: srcHashLen - 1];
	NSRange range = [BORDERS[dir][type] rangeOfString: lastChr];
	if (range.location != NSNotFound) {
		base = [RMGeoHash adjacentOf: base inDir: dir];
	}
	range = [NEIGHBORS[dir][type] rangeOfString: lastChr];
	return [base stringByAppendingString: [BASE32 substringWithRange:NSMakeRange(range.location, 1)]];
}


+ (NSArray *) withNeighbors: (NSString *)locHashcode 
{	
	NSMutableArray *neighborsHash = [[[NSMutableArray arrayWithCapacity: 9] retain] autorelease];
	
	NSString *neighborHash, *neighborHashRight, *neighborHashLeft;
	
	[neighborsHash addObject: locHashcode];
	
	neighborHash = [RMGeoHash adjacentOf:locHashcode inDir: RMGeoHashAtTop];
	[neighborsHash addObject: neighborHash];
	neighborHash = [RMGeoHash adjacentOf:locHashcode inDir: RMGeoHashAtBottom];
	[neighborsHash addObject: neighborHash];
	
	neighborHashLeft = [RMGeoHash adjacentOf:locHashcode inDir: RMGeoHashAtLeft];
	[neighborsHash addObject: neighborHashLeft];
	neighborHashRight = [RMGeoHash adjacentOf:locHashcode inDir: RMGeoHashAtRight];
	[neighborsHash addObject: neighborHashRight];
	
	neighborHash = [RMGeoHash adjacentOf: neighborHashLeft inDir: RMGeoHashAtTop];
	[neighborsHash addObject: neighborHash];
	neighborHash = [RMGeoHash adjacentOf: neighborHashLeft inDir: RMGeoHashAtBottom];
	[neighborsHash addObject: neighborHash];
	neighborHash = [RMGeoHash adjacentOf: neighborHashRight inDir: RMGeoHashAtTop];
	[neighborsHash addObject: neighborHash];
	neighborHash = [RMGeoHash adjacentOf: neighborHashRight inDir: RMGeoHashAtBottom];
	[neighborsHash addObject: neighborHash];
	
	return neighborsHash;
}

@end
