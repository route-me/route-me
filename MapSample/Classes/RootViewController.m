//
//  RootViewController.m
//  MapSample
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

#import "RootViewController.h"
#import "MainViewController.h"
#import "FlipsideViewController.h"


@implementation RootViewController

@synthesize infoButton;
@synthesize flipsideNavigationBar;
@synthesize mainViewController;
@synthesize flipsideViewController;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    MainViewController *viewController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
    self.mainViewController = viewController;
    [viewController release];
    
    [self.view insertSubview:mainViewController.view belowSubview:infoButton];
}


- (void)loadFlipsideViewController {
    
    FlipsideViewController *viewController = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
    self.flipsideViewController = viewController;
    [viewController release];
    
    // Set up the navigation bar
    UINavigationBar *aNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    aNavigationBar.barStyle = UIBarStyleBlackOpaque;
    self.flipsideNavigationBar = aNavigationBar;
    [aNavigationBar release];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleView)];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"MapSample"];
    navigationItem.rightBarButtonItem = buttonItem;
    [flipsideNavigationBar pushNavigationItem:navigationItem animated:NO];
    [navigationItem release];
    [buttonItem release];
}


- (IBAction)toggleView {    
    /*
     This method is called when the info or Done button is pressed.
     It flips the displayed view from the main view to the flipside view and vice-versa.
     */
    if (flipsideViewController == nil) {
        [self loadFlipsideViewController];
    }
    
    UIView *mainView = mainViewController.view;
    UIView *flipsideView = flipsideViewController.view;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    [UIView setAnimationTransition:([mainView superview] ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft) forView:self.view cache:YES];
    
    if ([mainView superview] != nil) {
        [flipsideViewController viewWillAppear:YES];
        [mainViewController viewWillDisappear:YES];
        [mainView removeFromSuperview];
        [infoButton removeFromSuperview];
        [self.view addSubview:flipsideView];
        [self.view insertSubview:flipsideNavigationBar aboveSubview:flipsideView];
        [mainViewController viewDidDisappear:YES];
        [flipsideViewController viewDidAppear:YES];

    } else {
        [mainViewController viewWillAppear:YES];
        [flipsideViewController viewWillDisappear:YES];
        [flipsideView removeFromSuperview];
        [flipsideNavigationBar removeFromSuperview];
        [self.view addSubview:mainView];
        [self.view insertSubview:infoButton aboveSubview:mainViewController.view];
        [flipsideViewController viewDidDisappear:YES];
        [mainViewController viewDidAppear:YES];
    }
    [UIView commitAnimations];
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


- (void)dealloc {
    [infoButton release];
    [flipsideNavigationBar release];
    [mainViewController release];
    [flipsideViewController release];
    [super dealloc];
}


@end
