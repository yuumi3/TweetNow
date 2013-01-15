//
//  AboutViewController.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 2012/11/11.
//  Copyright (c) 2012年 Yuumi Yoshida. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
@property (weak, nonatomic) IBOutlet UITextField *versionText;

@end

@implementation AboutViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	NSString *infoPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Info.plist"];
	NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:infoPath];
	_versionText.text = [info valueForKey:@"CFBundleVersion"];
}


@end
