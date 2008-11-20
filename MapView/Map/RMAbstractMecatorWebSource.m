//
//  RMMercatorWebSource.m
//  MapView
//
//  Created by Brian Knorr on 9/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMAbstractMecatorWebSource.h"
#import "RMTransform.h"
#import "RMTileImage.h"
#import "RMTileLoader.h"
#import "RMFractalTileProjection.h"
#import "RMTiledLayerController.h"
#import "RMProjection.h"

@implementation RMAbstractMecatorWebSource

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

-(RMTileImage *) tileImage: (RMTile)tile
{
	tile = [tileProjection normaliseTile:tile];
	RMTileImage* image = [RMTileImage imageWithTile: tile FromURL:[self tileURL:tile]];
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

@end

