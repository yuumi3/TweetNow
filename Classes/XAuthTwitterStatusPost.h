//
//  XAuthTwitterStatusPost.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 10/05/08.
//  Copyright 2010 EY-Office. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XAuthTwitterEngineDelegate.h"

@class XAuthTwitterEngine;

@interface XAuthTwitterStatusPost : NSObject  <XAuthTwitterEngineDelegate> {
	id       delegate;
	SEL      didSuccessSelector;
	SEL      didFailedSelector;
  @private
	XAuthTwitterEngine *twitterEngine;
	NSString *username;
	NSString *password;
	NSString *message;
}
@property (nonatomic, assign) id       delegate;
@property (nonatomic)         SEL      didSuccessSelector;
@property (nonatomic)         SEL      didFailedSelector;

- (XAuthTwitterStatusPost *) init;
- (void) setUserName:(NSString *)aUsername password:(NSString *)aPassword;
- (void) postMessage:(NSString *)aMessage timeoutInterval:(NSTimeInterval)timeoutInterval;

@end
