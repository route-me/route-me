//
//  RMConfiguration.m
//  MapView
//
//  Created by Hauke Brandes on 28.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMConfiguration.h"

static RMConfiguration* RMConfigurationSharedInstance = nil;

@implementation RMConfiguration

+ (RMConfiguration*) configuration
{
	
	@synchronized (RMConfigurationSharedInstance) {
		if (RMConfigurationSharedInstance != nil) return RMConfigurationSharedInstance;
	
		RMConfigurationSharedInstance = [[RMConfiguration alloc] 
										 initWithPath: [[NSBundle mainBundle] pathForResource:@"routeme" ofType:@"plist"]];

		return RMConfigurationSharedInstance;
	}
	return nil;
}


- (RMConfiguration*) initWithPath: (NSString*) path
{
	self = [super init];
	
	if (self==nil) return nil;
	
	NSData *plistData;
	NSString *error;
	NSPropertyListFormat format;

	if (path==nil) 
	{
		propList = nil;
		return self;
	}
	
	NSLog(@"reading configuration from %@", path);	
	plistData = [NSData dataWithContentsOfFile:path];

	propList = [[NSPropertyListSerialization 
					propertyListFromData:plistData
					mutabilityOption:NSPropertyListImmutable
					format:&format
					errorDescription:&error] retain];

	if(!propList)
	{
		NSLog(@"problem reading from %@: %@", path, error);
		[error release];
	}

	return self;
}
	

- (void) dealloc
{
	[propList release];
	[super dealloc];
}


- (NSDictionary*) cacheConfiguration
{
	if (propList==nil) return nil;
	return [propList objectForKey: @"caches"];
}

@end
