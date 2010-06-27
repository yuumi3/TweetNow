//
//  TweetNowAppDelegate.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/22.
//  Copyright EY-Office 2009. All rights reserved.
//

#import "TweetNowAppDelegate.h"
#import "TweetNowViewController.h"
#import "Config.h"
#import "RegisteredPlaceList.h"

@implementation TweetNowAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize navigationController;



- (void)applicationDidFinishLaunching:(UIApplication *)application {   
	[[Config sharedInstance] load];
    [[RegisteredPlaceList sharedInstance] load];
		
    [window addSubview:tabBarController.view];
	if (![Config sharedInstance].debug) {
		NSArray *tabs = self.tabBarController.viewControllers;
		self.tabBarController.viewControllers = [NSArray arrayWithObjects:[tabs objectAtIndex:0],
												 [tabs objectAtIndex:1], [tabs objectAtIndex:3], nil];
	}	
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}


@end
