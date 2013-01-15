//
//  AdBanner.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 2012/12/30.
//  Copyright (c) 2012年 Yuumi Yoshida. All rights reserved.
//

#import "AdBanner.h"
#import "GADBannerView.h"
#import "GADRequest.h"

#define ADMOB_BANNER_UNIT_ID   @"YOUR_ADMOB_BANNER_UNIT_ID"

@interface AdBanner()
@property(strong, nonatomic) GADBannerView *adBanner;
@end

@implementation AdBanner

- (id)initWithRootViewController:(UIViewController *)viewController {
    self = [super init];
    
    _adBanner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    _adBanner.translatesAutoresizingMaskIntoConstraints = NO;
    _adBanner.adUnitID = ADMOB_BANNER_UNIT_ID;
    _adBanner.delegate = (NSObject<GADBannerViewDelegate> *)viewController;

    [_adBanner setRootViewController:viewController];
    [viewController.view addSubview:_adBanner];
    [_adBanner loadRequest:[self createRequest]];
    
    [viewController.view addConstraint:
     [NSLayoutConstraint constraintWithItem:_adBanner
                                  attribute:NSLayoutAttributeBottom
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:viewController.view
                                  attribute:NSLayoutAttributeBottom
                                 multiplier:1.0
                                   constant:0]];
    [viewController.view addConstraint:
     [NSLayoutConstraint constraintWithItem:_adBanner
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:viewController.view
                                  attribute:NSLayoutAttributeCenterX
                                 multiplier:1.0
                                   constant:0]];
    
    return self;
}

- (GADRequest *)createRequest {
    GADRequest *request = [GADRequest request];
    request.testDevices =
        [NSArray arrayWithObjects:
         // TODO: Add your device/simulator test identifiers here. They are
         // printed to the console when the app is launched.
         nil];
    return request;
}

@end
