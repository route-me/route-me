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
#import "RMLatLongToMercatorProjection.h"

@implementation RMAbstractMecatorWebSource

-(id) init
{
	if (![super init])
		return nil;
	
	RMMercatorRect bounds;
	bounds.origin.x = -20037508.34;
	bounds.origin.y = -20037508.34;
	bounds.size.width = 20037508.34 * 2;
	bounds.size.height = 20037508.34 * 2;
	tileProjection = [[RMFractalTileProjection alloc] initWithBounds:bounds TileSideLength:256 MaxZoom:18];
	
	return self;
}

-(void) dealloc
{
	[tileProjection release];
	[super dealloc];
}

-(NSString*) tileURL: (RMTile) tile
{
	@throw [NSException exceptionWithName:@"RMAbstractMethodInvocation" reason:@"tileURL invoked on AbstractMercatorWebSource. Override this method when instantiating abstract class." userInfo:nil];
}

-(RMTileImage *) tileImage: (RMTile)tile
{
	RMTileImage* image = [RMTileImage imageWithTile: tile FromURL:[self tileURL:tile]];
	//		[cache addTile:tile WithImage:image];
	return image;
}

-(id<RMMercatorToTileProjection>) mercatorToTileProjection
{
	return [[tileProjection retain] autorelease];
}

-(RMLatLongToMercatorProjection*) latLongToMercatorProjection
{
	return [RMLatLongToMercatorProjection googleProjection];
}

-(RMMercatorRect) bounds
{
	return [tileProjection bounds];
}

//@synthesize cache;

@end

