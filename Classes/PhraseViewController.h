//
//  PhraseViewController.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 11/05/08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

@interface PhraseViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView     *phraseTable;
    UITextField     *newPhraseText;
    UIView          *textFrame;
    GADBannerView   *bannerView;
  @private
    int             editItemIndex;
    float           phraseTableHeigth;
    BOOL            addMode;
    UIImage         *listMark;
}

@property(nonatomic, retain) IBOutlet UITableView     *phraseTable;
@property(nonatomic, retain) IBOutlet UITextField     *newPhraseText;
@property(nonatomic, retain) IBOutlet UIView          *textFrame;

- (IBAction)onPushAdd:(id)sender;
- (IBAction)onPushEdit:(id)sender;

@end
