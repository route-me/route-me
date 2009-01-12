//
//  MapTools.m
//  freemap-iphone
//
//  Created by Michel Barakat on 10/20/08.
//  Copyright 2008 Høgskolen i Østfold. All rights reserved.
//

#import "MapTools.h"

@interface MapTools (Private)
+ (MapCoordinates*)computeCoordinatesFromX:(int) x Y:(int) y AtZoom:(int) zoom;
@end

@implementation MapTools

+ (CGPoint)mapTileXYFromMapCoordinates:(MapCoordinates*) mapCoordinates 
								AtZoom:(int) zoom {
	NSLog(@"MapTools::mapTileXYFromMapCoordinatesAtZoom");
	assert(mapCoordinates != 0);
	assert(zoom >= 0); // full sanity checking done in MapTile
	
	const double latitude = [mapCoordinates latitude];
	double longitude = [mapCoordinates longitude];
  
	// Conversion formulas provided by OSM community.
	// Get tile-x from longitude (east to west).
	CGPoint mapTileXY;
	mapTileXY.x = (int)(floor((longitude + 180.0) / 360.0 * pow(2.0, zoom)));
	// Get tile-y from latitude (north to south).
	mapTileXY.y = (int)(floor((1.0 - log( tan(latitude * M_PI/180.0) +
			1.0 / cos(latitude * M_PI/180.0)) / M_PI) / 2.0 * pow(2.0, zoom)));
	
  NSLog(@"MapTools::mapTileXY x: %f y: %f", mapTileXY.x, mapTileXY.y);
  
	return mapTileXY;
}

+ (BoundBox*)boundBoxFromMapTile:(MapTile*) mapTile {
	NSLog(@"MapTools::boundBoxFromMapTile");
	assert(mapTile != 0);
	
	MapCoordinates* northWestCoordinates = [MapTools computeCoordinatesFromX:
									mapTile.x Y:mapTile.y AtZoom:mapTile.zoom];
	// South east coordinates of the map tile are simply the north west
	// coordinates of the first map tile on the south east.
	MapCoordinates* southEastCoordinates =
		[MapTools computeCoordinatesFromX:(mapTile.x + 1) Y:(mapTile.y + 1) 
							   AtZoom:mapTile.zoom];
	
	BoundBox* boundBox = [[BoundBox alloc] initWithCoordinatesNorthWest:
						  northWestCoordinates SouthEast:southEastCoordinates];
  
  [northWestCoordinates release];
  [southEastCoordinates release];
  
	return boundBox;
}

// The offset returned is the position of the target coordinates in the map tile
// relative to the center point of the map tile. The coordinate system used is:
// X East-West and Y South-North.
+ (CGPoint)tileCenterOffsetFromMapTile:(MapTile*) mapTile {
	NSLog(@"MapTools::tileRelativeCenterFromMapTile");
	assert(mapTile != 0);
	
	MapCoordinates *centerCoords = [[mapTile mapState] centerCoords];
	BoundBox* mapTileBoundBox = [MapTools boundBoxFromMapTile:mapTile];
	const CGSize tileSize = [[[mapTile mapState] mapSource] tileSize];
	
	const double xOffset =
		((([centerCoords longitude] - [mapTileBoundBox westLongitude]) / 
		  ([mapTileBoundBox eastLongitude] - [mapTileBoundBox westLongitude])) * 
		 tileSize.width) - (tileSize.width / 2);
	
	const double yOffset = 
		((([centerCoords latitude] - [mapTileBoundBox northLatitude]) /
		  ([mapTileBoundBox southLatitude] - [mapTileBoundBox northLatitude])) *
		 tileSize.height) - (tileSize.height / 2);
	
	[mapTileBoundBox release];
	
	CGPoint tileCenterOffset;
	tileCenterOffset.x = xOffset;
	tileCenterOffset.y = yOffset;
	
	return tileCenterOffset;
}

@end

@implementation MapTools (Private)
+ (MapCoordinates*)computeCoordinatesFromX:(int) x Y:(int) y AtZoom:(int) zoom {
	// TODO: Add valid checking.
	assert(x >= 0);
	assert(y >= 0);
	assert(zoom >= 0);
	
	// Conversion formulas provided by OSM community.
	MapCoordinates *coordinates = [MapCoordinates alloc];
	// Get longitude (east to west) from tile-x.
	coordinates.longitude = x / pow(2.0, zoom) * 360.0 - 180.0;
	// Get latitude (north to south) from tile-y;
	const double n = M_PI - 2.0 * M_PI * y / pow(2.0, zoom);
	coordinates.latitude = 180.0 / M_PI * atan(0.5 * (exp(n) - exp(-n)));
	
	return coordinates;
}
@end
