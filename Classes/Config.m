//
//  Config.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/23.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import "Config.h"
#import "SFHFKeychainUtils.h"
#import "SimpleAlertView.h"
#import "TNLogger.h"

// default database の格納キー
#define DB_VERSION			103					// 103 は 102 と同じだがKEYCHAINにXAuthAccessTokenを格納
#define DB_VERSION_102		102					// 102 で PASSWORD, GPSTIME が無くなった
#define DB_VERSION_101		101					// パスワードを保存していた 
#define CONFIG_DB_VERSION	@"configDbVersion"
#define CONFIG_LOGIN		@"configLogin"
#define CONFIG_PASSWORD		@"configPassword"
#define CONFIG_PREFIX		@"configPrefix"
#define CONFIG_POSTFIX		@"configPostfix"
#define CONFIG_GPSTIME		@"configGpsTime"
#define CONFIG_LOGUPURL		@"configLogUpUrl"
#define CONFIG_DEBUG		@"configDebug"

//
static Config *sharedInstanceDelegate = nil;



@implementation Config
@synthesize dbVersion;
@synthesize login;
@synthesize password;
@synthesize prefix;
@synthesize postfix;
@synthesize debug;
@synthesize logUpUrl;
@synthesize xAuthToken;


//
- (void)load {
	NSError *error = nil;

	dbVersion = [[NSUserDefaults standardUserDefaults] integerForKey:CONFIG_DB_VERSION];
	if (dbVersion == 0) {
		self.dbVersion = DB_VERSION;
		self.login	  = @"";
		self.password = @"";
		self.prefix   = @"";
		self.postfix  = @" なう";
		self.logUpUrl = @"";
        self.xAuthToken = @"";
		self.debug    = NO;
	} else {
		self.login     = [[NSUserDefaults standardUserDefaults] stringForKey:CONFIG_LOGIN];
		self.prefix    = [[NSUserDefaults standardUserDefaults] stringForKey:CONFIG_PREFIX];
		self.postfix   = [[NSUserDefaults standardUserDefaults] stringForKey:CONFIG_POSTFIX];
		self.logUpUrl  = [[NSUserDefaults standardUserDefaults] stringForKey:CONFIG_LOGUPURL];
		self.debug     = [[NSUserDefaults standardUserDefaults]   boolForKey:CONFIG_DEBUG];	

		if (dbVersion == DB_VERSION_101) {
			TNLog(@"++ DB version up %d -> %d", dbVersion, DB_VERSION);
			NSString *savedPassword = [[NSUserDefaults standardUserDefaults] stringForKey:CONFIG_PASSWORD];
			[SFHFKeychainUtils storeUsername:login andPassword:savedPassword forServiceName:SERVICE_NAME_FOR_KEYCHAIN_LOGIN updateExisting:YES
                                       error:&error];
			if (error) {
				TNLog(@"SFHFKeychainUtils store fail: %@", error);
				[SimpleAlertView alertWithTitle:@"パスワードエラー" message:@"Twitterパスワードをキーチェインに移行するのに失敗しました"];
			}
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:CONFIG_PASSWORD];
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:CONFIG_GPSTIME];
			[[NSUserDefaults standardUserDefaults] setInteger:DB_VERSION forKey:CONFIG_DB_VERSION];
		}
		self.password = [SFHFKeychainUtils getPasswordForUsername:login andServiceName:SERVICE_NAME_FOR_KEYCHAIN_LOGIN error:&error];
		if (!self.password) {
			TNLog(@"SFHFKeychainUtils store fail: %@", error);
			[SimpleAlertView alertWithTitle:@"パスワードエラー" message:@"Twitterのパスワードを設定して下さい"];
			self.password = @"" ;
		}
        self.xAuthToken = [SFHFKeychainUtils getPasswordForUsername:login andServiceName:SERVICE_NAME_FOR_KEYCHAIN_XAUTH error:&error];
        if (!self.password) {
            self.xAuthToken = @"";
        }
	}
}

//
- (void)save {
	NSError  *error = nil;
	[SFHFKeychainUtils storeUsername:login andPassword:password forServiceName:SERVICE_NAME_FOR_KEYCHAIN_LOGIN updateExisting:YES error:&error];
	if (error) {
		TNLog(@"SFHFKeychainUtils store fail: %@", error);
		[SimpleAlertView alertWithTitle:@"パスワード保存失敗" message:@"パスワードをキーチェインに保存するのに失敗しました"];
	}
    error = nil;
	[SFHFKeychainUtils storeUsername:login andPassword:xAuthToken forServiceName:SERVICE_NAME_FOR_KEYCHAIN_XAUTH updateExisting:YES error:&error];
	if (error) {
		TNLog(@"SFHFKeychainUtils store fail: %@", error);
		[SimpleAlertView alertWithTitle:@"パスワード保存失敗" message:@"パスワードをキーチェインに保存するのに失敗しました"];
	}
	[[NSUserDefaults standardUserDefaults] setInteger:dbVersion forKey:CONFIG_DB_VERSION];
	[[NSUserDefaults standardUserDefaults] setObject:login      forKey:CONFIG_LOGIN]; 
	[[NSUserDefaults standardUserDefaults] setObject:prefix     forKey:CONFIG_PREFIX];
	[[NSUserDefaults standardUserDefaults] setObject:postfix    forKey:CONFIG_POSTFIX];
	[[NSUserDefaults standardUserDefaults] setObject:logUpUrl   forKey:CONFIG_LOGUPURL];
	[[NSUserDefaults standardUserDefaults] setBool:debug        forKey:CONFIG_DEBUG];
}


// http://blog.quazie.net/2009/04/sharedinstance-objective-cs-singleton-paradigm/

+ (Config *)sharedInstance {
	@synchronized(self) {
		if (sharedInstanceDelegate == nil) {
			[[self alloc] init]; // assignment not done here
		}
	}
	return sharedInstanceDelegate;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (sharedInstanceDelegate == nil) {
			sharedInstanceDelegate = [super allocWithZone:zone];
			// assignment and return on first allocation
			return sharedInstanceDelegate;
		}
	}
	// on subsequent allocation attempts return nil
	return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain {
	return self;
}

- (unsigned)retainCount {
	return UINT_MAX;  // denotes an object that cannot be released
}

- (oneway void)release {
	//do nothing
}

- (id)autorelease {
	return self;
}


@end
