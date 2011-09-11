//
//  PlacesViewController.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/25.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddPlaceViewController.h"
#import "GADBannerView.h"


@interface PlacesViewController : UIViewController <UITableViewDelegate> {
	UITableView *placesList;
	AddPlaceViewController *addPlaceViewController;
    GADBannerView *bannerView;
  @private
    UIImage  *listMark;
}
@property (nonatomic, retain) IBOutlet UITableView *placesList;
@property (nonatomic, retain) IBOutlet AddPlaceViewController *addPlaceViewController;

- (IBAction)onPushEdit:(id)sender;
- (IBAction)onPushAdd:(id)sender;
- (BOOL)toggleEditingMode;

@end
