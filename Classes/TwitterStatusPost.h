//
//  XAuthTwitterStatusPost.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 10/05/08.
//  Copyright 2010 EY-Office. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGTwitterEngine.h"
#import "MGTwitterEngineDelegate.h"

@class XAuthTwitterEngine;

@interface TwitterStatusPost : NSObject  <MGTwitterEngineDelegate> {
	id       delegate;
	SEL      didSuccessSelector;
	SEL      didFailedSelector;
  @private
	MGTwitterEngine *twitterEngine;
	NSString *username;
	NSString *password;
	NSString *message;
}
@property (nonatomic, assign) id       delegate;
@property (nonatomic)         SEL      didSuccessSelector;
@property (nonatomic)         SEL      didFailedSelector;

- (TwitterStatusPost *) init;
- (void) setUserName:(NSString *)aUsername password:(NSString *)aPassword;
- (void) postMessage:(NSString *)aMessage timeoutInterval:(NSTimeInterval)timeoutInterval;

@end
