//
//  TweetNowAppDelegate.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/22.
//  Copyright EY-Office 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlacesViewController.h"
#import "PhraseViewController.h"

@class PlacesViewController;
@class PhraseViewController;

@interface TweetNowAppDelegate : NSObject <UIApplicationDelegate> {
    IBOutlet UIWindow *window;
    IBOutlet UITabBarController *tabBarController;
	IBOutlet UINavigationController *navigationController;
    IBOutlet PlacesViewController *placesViewController;
    IBOutlet PhraseViewController *phraseViewController;
 }

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet PlacesViewController *placesViewController;
@property (nonatomic, retain) IBOutlet PhraseViewController *phraseViewController;

@end

