//
//  TweetNowAppDelegate.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/22.
//  Copyright EY-Office 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlacesViewController.h"

@class TweetNowViewController;

@interface TweetNowAppDelegate : NSObject <UIApplicationDelegate> {
    IBOutlet UIWindow *window;
    IBOutlet UITabBarController *tabBarController;
	IBOutlet UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;


@end

