//
//  AboutViewController.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 10/01/04.
//  Copyright 2010 EY-Office. All rights reserved.
//

#import "AboutViewController.h"
#import "Config.h"

@implementation AboutViewController
@synthesize debugButton;
@synthesize versionText;
@synthesize textView;


#pragma mark View and memory management methods.

- (void)viewDidUnload {
	self.debugButton = nil;
	self.versionText = nil;
	self.textView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	textView.font = [UIFont systemFontOfSize:14.0];
	debugButton.backgroundColor = [Config sharedInstance].debug ? [UIColor redColor] : [UIColor whiteColor];
	
	NSString *infoPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Info.plist"];
	NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:infoPath];
	versionText.text = [info valueForKey:@"CFBundleVersion"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[debugButton release];
	[versionText release];
	[textView release];
    [super dealloc];
}


#pragma mark Event handle methods.

- (IBAction)onPushDebug:(id)sender {
	Config *config = [Config sharedInstance]; 
	config.debug = !config.debug;
	[config save];
	debugButton.backgroundColor = config.debug ? [UIColor redColor] : [UIColor whiteColor];
}




@end
