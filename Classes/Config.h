//
//  Config.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/23.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SERVICE_NAME_FOR_KEYCHAIN_LOGIN @"TweetNow101"
#define SERVICE_NAME_FOR_KEYCHAIN_XAUTH @"TweetNowXAuth"

@interface Config : NSObject {
	int       dbVersion;
	NSString  *login;
	NSString  *password;
	NSString  *prefix;
	NSString  *postfix;
	NSString  *logUpUrl;
    NSString  *xAuthToken;
	BOOL      debug;
}
@property (nonatomic, retain) NSString *login;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *prefix;
@property (nonatomic, retain) NSString *postfix;
@property (nonatomic, retain) NSString *logUpUrl;
@property (nonatomic, retain) NSString *xAuthToken;
@property (nonatomic)         BOOL     debug;
@property (nonatomic)         int      dbVersion;


+ (Config *)sharedInstance;
- (void)load;
- (void)save;

@end
