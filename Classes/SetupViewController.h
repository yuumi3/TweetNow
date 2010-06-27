//
//  SetupViewController.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 10/01/04.
//  Copyright 2010 EY-Office. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AboutViewController.h"
#import "Config.h"


@interface SetupViewController : UITableViewController <UITextFieldDelegate> {
	AboutViewController  *aboutViewController;

	UITextField  *login;
	UITextField  *password;
	UITextField  *prefix;
	UITextField  *postfix;
	UITextField  *logUpUrl;
  @private
	Config		 *config;
}
@property (nonatomic, retain) IBOutlet AboutViewController *aboutViewController;
@property (nonatomic, retain) UITextField  *login;
@property (nonatomic, retain) UITextField  *password;
@property (nonatomic, retain) UITextField  *prefix;
@property (nonatomic, retain) UITextField  *postfix;
@property (nonatomic, retain) UITextField  *logUpUrl;

- (IBAction)onPushSave:(id)sender;


@end
