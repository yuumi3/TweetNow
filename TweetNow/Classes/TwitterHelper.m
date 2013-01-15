//
//  XAuthTwitterStatusPost.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 10/05/08.
//  Copyright 2010 EY-Office. All rights reserved.
//

#import "TwitterHelper.h"
#import "SimpleAlertView.h"
#import "Config.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

#define TWITTER_POST_STATUSES_UPDATE_URL @"https://api.twitter.com/1.1/statuses/update.json"


#pragma mark -
@implementation TwitterHelper

+ (void)getTwitterAccountsWithCompletion:(void(^)(NSArray *accounts))completion {
    ACAccountStore *accountStore = [[ACAccountStore alloc]init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(!granted){
            completion(nil);
            NSLog(@"Not granted");
        } else {
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            if (accounts != nil && [accounts count] > 0) {
                completion(accounts);
            } else {
                completion(nil);
                NSLog(@"No accounts");
            }
        }
    }];
}


+ (void)postMessage:(NSString *)aMessage completion:(void(^)(NSString *errorMessage))completion {
    [TwitterHelper getTwitterAccountsWithCompletion:^(NSArray *accounts) {
        if (!accounts) {
            completion(@"Twitterアカウントが正しくありません");
        } else {
            NSURL *url = [NSURL URLWithString:TWITTER_POST_STATUSES_UPDATE_URL];
            NSDictionary *params = [NSDictionary dictionaryWithObject:aMessage forKey:@"status"];
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:url parameters:params];
            request.account = accounts[0];
            [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                if ([urlResponse statusCode] == 200) {
                    completion(nil);
                }
                else {
                    completion(@"二重投稿やネットワーク、サービスの障害などが考えられます");
                    NSLog(@"Twitter get error %d %@", [urlResponse statusCode], error);
                }
            }];
        }
    }];
}



@end
