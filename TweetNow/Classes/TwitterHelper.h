//
//  XAuthTwitterStatusPost.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 10/05/08.
//  Copyright 2010 EY-Office. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterHelper : NSObject

+ (void)getTwitterAccountsWithCompletion:(void(^)(NSArray *accounts))completion;
+ (void)postMessage:(NSString *)aMessage completion:(void(^)(NSString *errorMessage))completion;

@end
