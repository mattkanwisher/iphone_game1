//
//  ianimateAppDelegate.m
//  ianimate
//
//  Created by Shannon Appelcline on 10/17/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "ianimateAppDelegate.h"
#import "ianimateViewController.h"
#import "QuartzUtils.h"
#import "ImageLayer.h"

@implementation ianimateAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
	[application setStatusBarHidden:YES animated:NO];
	
    // Override point for customization after app launch    
//    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    //window.layer.backgroundColor = GetCGPatternNamed(@"back2.png");
	[window addSubview:viewController.view];
	 
	
	[window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
