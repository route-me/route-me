//
//  MainViewController.m
//  Images
//
//  Created by Joseph Gentle on 13/08/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"

#import "MapView.h"

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Custom initialization
		
		// I don't really understand why, but I need to mention MapView
		// somewhere here for the interface builder file to load correctly.
		[MapView class];
	}
	return self;
}

// If you need to do additional setup after loading the view, override viewDidLoad.
// - (void)viewDidLoad {
// }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}


@end
