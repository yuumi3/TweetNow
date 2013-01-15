//
//  SetUpViewController.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 2012/11/11.
//  Copyright (c) 2012年 Yuumi Yoshida. All rights reserved.
//

#import "SetUpViewController.h"

#import "Config.h"

@interface SetUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *prefixText;
@property (weak, nonatomic) IBOutlet UITextField *postfixText;
@property (weak, nonatomic) IBOutlet UITextField *hashTagText;

- (IBAction)onPushSave:(id)sender;

@end

@implementation SetUpViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	Config *config = [Config sharedInstance];
	[config load];
    
    _prefixText.text  = config.prefix;
    _postfixText.text = config.postfix;
    _hashTagText.text = config.hashTag;
}

- (IBAction)onPushSave:(id)sender {
	Config *config = [Config sharedInstance];
	
    config.prefix  = _prefixText.text;
    config.postfix = _postfixText.text;
    config.hashTag = _hashTagText.text;
    [config save];

    self.tabBarController.selectedIndex = 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *aboutViewController = [segue destinationViewController];
    aboutViewController.hidesBottomBarWhenPushed = YES;
}

@end
