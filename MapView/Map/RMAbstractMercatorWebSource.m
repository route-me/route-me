//
//  RMMercatorWebSource.m
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

#import "RMAbstractMercatorWebSource.h"
#import "RMTransform.h"
#import "RMTileImage.h"
#import "RMTileLoader.h"
#import "RMFractalTileProjection.h"
#import "RMTiledLayerController.h"
#import "RMProjection.h"

@implementation RMAbstractMercatorWebSource

-(id) init
{
	if (![super init])
		return nil;
	
	int sideLength = [[self class] tileSideLength];
	tileProjection = [[RMFractalTileProjection alloc] initFromProjection:[self projection] tileSideLength:sideLength maxZoom:18];
	
	return self;
}

-(void) dealloc
{
	[tileProjection release];
	[super dealloc];
}

+(int)tileSideLength
{
	return 256;
}

-(float) minZoom
{
	return 0;
}
-(float) maxZoom
{
	return 18;
}

-(NSString*) tileURL: (RMTile) tile
{
	@throw [NSException exceptionWithName:@"RMAbstractMethodInvocation" reason:@"tileURL invoked on AbstractMercatorWebSource. Override this method when instantiating abstract class." userInfo:nil];
}

-(NSString*) tileFile: (RMTile) tile
{
	return nil;
}

-(NSString*) tilePath
{
	return nil;
}

-(RMTileImage *) tileImage: (RMTile)tile
{
	RMTileImage *image;
	
	tile = [tileProjection normaliseTile:tile];

	NSString *file = [self tileFile:tile];

	if(file && [[NSFileManager defaultManager] fileExistsAtPath:file])
	{
		image = [RMTileImage imageWithTile:tile FromFile:file];
	} else {
       		image = [RMTileImage imageWithTile:tile FromURL:[self tileURL:tile]];     
	}
	
	return image;
}

-(id<RMMercatorToTileProjection>) mercatorToTileProjection
{
	return [[tileProjection retain] autorelease];
}

-(RMProjection*) projection
{
	return [RMProjection googleProjection];
}

-(void) didReceiveMemoryWarning
{
	LogMethod();
}

-(NSString *)uniqueTilecacheKey
{
	@throw [NSException exceptionWithName:@"RMAbstractMethodInvocation" reason:@"uniqueTilecacheKey invoked on AbstractMercatorWebSource. Override this method when instantiating abstract class." userInfo:nil];
}

-(NSString *)shortName
{
	@throw [NSException exceptionWithName:@"RMAbstractMethodInvocation" reason:@"shortName invoked on AbstractMercatorWebSource. Override this method when instantiating abstract class." userInfo:nil];
}
-(NSString *)longDescription
{
	return [self shortName];
}
-(NSString *)shortAttribution
{
	@throw [NSException exceptionWithName:@"RMAbstractMethodInvocation" reason:@"shortAttribution invoked on AbstractMercatorWebSource. Override this method when instantiating abstract class." userInfo:nil];
}
-(NSString *)longAttribution
{
	return [self shortAttribution];
}

@end

