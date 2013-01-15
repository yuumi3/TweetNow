//
//  Config.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/23.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import "Config.h"
#import "SimpleAlertView.h"

// default database の格納キー
#define DB_VERSION			104					// 104 login,password,logUpUrl,xAuthTokenho保存をやめ
#define DB_VERSION_103		103					// 103 は 102 と同じだがKEYCHAINにXAuthAccessTokenを格納
#define DB_VERSION_102		102					// 102 で PASSWORD, GPSTIME が無くなった
#define DB_VERSION_101		101					// パスワードを保存していた 
#define CONFIG_DB_VERSION	@"configDbVersion"
#define CONFIG_PREFIX		@"configPrefix"
#define CONFIG_POSTFIX		@"configPostfix"
#define CONFIG_HASHTAG      @"confugHashTag"
#define CONFIG_DEBUG		@"configDebug"




@implementation Config

- (void)load {
	_dbVersion = [[NSUserDefaults standardUserDefaults] integerForKey:CONFIG_DB_VERSION];
	if (_dbVersion == 0) {
		_dbVersion = DB_VERSION;
		_prefix   = @"";
		_postfix  = @" なう";
        _hashTag  = @"";
		_debug    = NO;
	} else {
		_prefix    = [[NSUserDefaults standardUserDefaults] stringForKey:CONFIG_PREFIX];
		_postfix   = [[NSUserDefaults standardUserDefaults] stringForKey:CONFIG_POSTFIX];
		_hashTag   = [[NSUserDefaults standardUserDefaults] stringForKey:CONFIG_HASHTAG];
		_debug     = [[NSUserDefaults standardUserDefaults]   boolForKey:CONFIG_DEBUG];
        if (!_hashTag) {
            _hashTag = @"";
        }
	}
}


- (void)save {
	[[NSUserDefaults standardUserDefaults] setInteger:_dbVersion forKey:CONFIG_DB_VERSION];
	[[NSUserDefaults standardUserDefaults] setObject:_prefix     forKey:CONFIG_PREFIX];
	[[NSUserDefaults standardUserDefaults] setObject:_postfix    forKey:CONFIG_POSTFIX];
	[[NSUserDefaults standardUserDefaults] setObject:_hashTag    forKey:CONFIG_HASHTAG];
	[[NSUserDefaults standardUserDefaults] setBool:_debug        forKey:CONFIG_DEBUG];
}

+ (Config *)sharedInstance {
    static Config *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Config alloc] init];
    });
    return sharedInstance;
}



@end
