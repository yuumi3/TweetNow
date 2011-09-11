//
//  AddPlaceViewController.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/25.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>  
#import "RegisteredPlaceList.h"

@interface AddPlaceViewController : UIViewController  <UITextFieldDelegate> {
    MKMapView		*mapView;  
	UITextField		*nameTextField;
	UIBarButtonItem	*saveButton;
    UIView          *textFrame;
  @private
	Place		*newPlace;
	BOOL		mapLocked;
}
@property (nonatomic, retain) IBOutlet MKMapView		*mapView;  
@property (nonatomic, retain) IBOutlet UITextField		*nameTextField;
@property (nonatomic, retain) IBOutlet UIBarButtonItem	*saveButton;
@property (nonatomic, retain) IBOutlet UIView           *textFrame;

- (IBAction)onPushDone:(id)sender;
- (IBAction)startEditTextField:(id)sender;

@end
