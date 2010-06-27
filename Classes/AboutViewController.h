//
//  AboutViewController.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 10/01/04.
//  Copyright 2010 EY-Office. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AboutViewController : UIViewController {
	UIButton    *debugButton;
	UITextField *versionText;
	UITextView	 *textView;
}
@property (nonatomic, retain) IBOutlet UIButton		*debugButton;
@property (nonatomic, retain) IBOutlet UITextField	*versionText;
@property (nonatomic, retain) IBOutlet UITextView	*textView;

- (IBAction)onPushDebug:(id)sender;

@end
