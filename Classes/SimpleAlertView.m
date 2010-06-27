//
//  SimpleAlertView.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 10/05/09.
//  Copyright 2010 EY-Office. All rights reserved.
//

#import "SimpleAlertView.h"


@implementation SimpleAlertView

+ (void) alertWithTitle:(NSString *)title message:(NSString *)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message
											  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}


@end
