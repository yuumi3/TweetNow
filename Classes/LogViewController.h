//
//  LogViewController.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/25.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LogViewController : UIViewController {
	UITextView	*textView;
	UIButton	*uploadButton;
    UIAlertView *clearConfirmAlertView;
}
@property (nonatomic, retain) IBOutlet UITextView	*textView;
@property (nonatomic, retain) IBOutlet UIButton		*uploadButton;
@property (nonatomic, retain) IBOutlet UIAlertView  *clearConfirmAlertView;

- (IBAction)onPushClearLog:(id)sender;
- (IBAction)onPushUploadLog:(id)sender;

@end
