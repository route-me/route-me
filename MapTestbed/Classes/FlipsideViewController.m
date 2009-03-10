//
//  FlipsideViewController.m
//  MapTestbed
//
//  Created by Hal Mueller on 3/9/09.
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
//

#import "FlipsideViewController.h"
#import "MapSampleAppDelegate.h"
#import "MyMapView.h"

@implementation FlipsideViewController

#pragma mark -
#pragma mark properties

@synthesize centerLat;
@synthesize centerLon;
@synthesize zoomLevel;
@synthesize rmscale;
@synthesize truescale;


// init
- (id)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];  
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"viewDidAppear");
	RMMapContents *contents = [(MapSampleAppDelegate *)[[UIApplication sharedApplication] delegate] mapContents];
	CLLocationCoordinate2D mapCenter = [contents mapCenter];
	[centerLat setText:[NSString stringWithFormat:@"%f", mapCenter.latitude]];
	[centerLon setText:[NSString stringWithFormat:@"%f", mapCenter.longitude]];
	[zoomLevel setText:[NSString stringWithFormat:@"%.2f", [contents zoom]]];
	float routemeMetersPerPixel = [contents scale]; // really meters/pixel
	[rmscale setText:[NSString stringWithFormat:@"%.1f", routemeMetersPerPixel]];
	
	float iphoneMillimetersPerPixel = .1543;
	float truescaleDenominator =  routemeMetersPerPixel / (0.001 * iphoneMillimetersPerPixel) ;
	[truescale setText:[NSString stringWithFormat:@"1:%.0f", truescaleDenominator]];
}

- (void)dealloc {
    self.centerLat = nil;
    self.centerLon = nil;
    self.zoomLevel = nil;
    self.rmscale = nil;
    self.truescale = nil;
    [super dealloc];
}


@end
