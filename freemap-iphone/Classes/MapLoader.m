//
//  MapLoader.m
//  freemap-iphone
//
//  Created by Michel Barakat on 11/5/08.
//  Copyright 2008 Høgskolen i Østfold. All rights reserved.
//

#import "MapLoader.h"

static BOOL initialized = false;
static BOOL canFetch = false;
static NSLock* loaderLock;

static NSMutableArray* mapTilesArray;
static NSMutableArray* tileFileArray;
static NSMutableArray* tileURLArray;

@implementation MapLoader

+ (void)initAll {
  NSLog(@"MapLoader::initAll");
  if (initialized) {
    return;
  }
  
  loaderLock = [[NSLock alloc] init];
  mapTilesArray = [[NSMutableArray alloc] init];
  tileFileArray = [[NSMutableArray alloc] init];
  tileURLArray = [[NSMutableArray alloc] init];
  
  initialized = true;
  canFetch = true;
  
  [NSThread detachNewThreadSelector:@selector(loaderThread:) 
                           toTarget:[MapLoader class] withObject:nil];
}

+ (void)loaderThread:(id)param {
  
  NSThread *fetchingThread = [[NSThread alloc] initWithTarget:[MapLoader class] 
                                   selector:@selector(fetchThread:) object:nil];
  
  [fetchingThread start];
  while (1) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if (canFetch && [fetchingThread isFinished]) {
      [fetchingThread release];
      fetchingThread = [[NSThread alloc] initWithTarget:[MapLoader class] 
                                   selector:@selector(fetchThread:) object:nil];
      [fetchingThread start];
    }
    [pool release];
    [NSThread sleepForTimeInterval:0.01];
  }
}

+ (void)fetchThread:(id)param {
  assert(initialized);

  [loaderLock lock];
  if ([mapTilesArray count] != 0) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    MapTile* mapTile = [mapTilesArray objectAtIndex:0];
    NSString* fileName = [tileFileArray objectAtIndex:0];
    NSString* imageUrl = [tileURLArray objectAtIndex:0];
    const CGSize tileSize = [[[mapTile mapState] mapSource] tileSize];
    
    NSData *data =[NSData dataWithContentsOfFile:fileName];
    // Download image if not in cache.
    if (data == 0) {
      NSLog(@"URL: %@", imageUrl); // remove
      
      NSURL *url = [NSURL URLWithString:imageUrl];
      NSError *error;
      // TODO: the following seems to hang the application for a couple of 
      // seconds because loading is not as smooth as expected.
      // Try to do asynchronous request instead.
      NSURLRequest *request = [NSURLRequest requestWithURL:url];
      data = [NSURLConnection sendSynchronousRequest:request 
                                   returningResponse:nil error:&error];
      
      if (data != 0) {
        assert([data writeToFile:fileName atomically:true]);
      }
    }

    UIImage *uiImage;
    if (data != 0) {
      NSLog(@"File name: %@", fileName); // remove
      uiImage = [UIImage imageWithData:data];
      
      assert(uiImage.size.width == tileSize.width && 
             uiImage.size.height == tileSize.height);
    } else {
      uiImage = [[[mapTile mapState] mapSource] failedImage];
    }
    
    @synchronized(mapTile) {
      [mapTile setImage:uiImage];
      [mapTile setNeedsDisplay];
    }
    
    [mapTilesArray removeObjectAtIndex:0];
    [tileFileArray removeObjectAtIndex:0];
    [tileURLArray removeObjectAtIndex:0];
    [pool release];
  }
  [loaderLock unlock];
}

+ (void)loadImageFromX:(int) x Y:(int) y InTile:(MapTile*) mapTile {
  //NSLog(@"MapLoader::loadImageFromXYInTile");
  assert(x >= 0);
	assert(y >= 0);
  assert(mapTile != 0);
  
  MapSource* mapSource =[[mapTile mapState] mapSource];
  int zoom = [[mapTile mapState] zoom];
  
  // TODO: Make static.
  NSString *writeDir = [NSString stringWithFormat:@"%@/Documents/",
                        NSHomeDirectory()];
  
  // File location if it exists.
  NSString *fileName = [NSString stringWithFormat:@"%@/%@-%d-%d-%d.png", 
                        writeDir, [mapSource dirName], zoom, x, y];
  
  // Sample url looks as follows: BASE/zoom/x/y.png
  NSString *imageUrl = [NSString stringWithFormat:@"%@%d/%d/%d.png",
                        [mapSource baseUrl], zoom, x, y];
  
  [loaderLock lock];
  [mapTilesArray addObject:mapTile];
  [tileFileArray addObject:fileName];
  [tileURLArray addObject:imageUrl];
  [loaderLock unlock];
}

+ (void)pauseFetching {
  //NSLog(@"MapLoader::pauseFetching");
  canFetch = false;
}

+ (void)resumeFetching {
  //NSLog(@"MapLoader::resumeFetching");
  canFetch = true;
}

+ (void)stopMapTileFetch:(MapTile*) mapTile {
  //NSLog(@"MapLoader::stopMapTileFetch");
  assert(mapTile != 0);
  
  [loaderLock lock];
  int index = [mapTilesArray indexOfObject:mapTile];
  if (index != NSNotFound) {
    [mapTilesArray removeObjectAtIndex:index];
    [tileFileArray removeObjectAtIndex:index];
    [tileURLArray removeObjectAtIndex:index];
  }
  [loaderLock unlock];
}

@end
