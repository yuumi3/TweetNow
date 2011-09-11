//
//  TweetNowViewController.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/21.
//  Copyright EY-Office 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>  
#import "StationSearch.h"
#import "TwitterStatusPost.h"

@interface TweetNowViewController : UIViewController <MKMapViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
    MKMapView		*placeMapView;  
	UITextField		*postText;
	UIImageView		*splash;
	UIBarButtonItem *postButton;
	UIView			*bussyMaskView;
    UITableView     *phraseTable;
    UIView          *textFrame;
    
  @private
	TwitterStatusPost *twetterPost;
	PlaceList		*placeList;
	Place			*lastPoint;
	BOOL			mapLocked;
}
@property (nonatomic, retain) IBOutlet MKMapView		*placeMapView;
@property (nonatomic, retain) IBOutlet UITextField		*postText;
@property (nonatomic, retain) IBOutlet UIImageView		*splash;
@property (nonatomic, retain) IBOutlet UIBarButtonItem	*postButton;
@property (nonatomic, retain) IBOutlet UIView			*bussyMaskView;
@property (nonatomic, retain) IBOutlet UITableView      *phraseTable;
@property (nonatomic, retain) IBOutlet UIView           *textFrame;

- (IBAction)onPushPost:(id)sender;
- (IBAction)onPushRefresh:(id)sender;
- (IBAction)startEditTextField:(id)sender;

@end

