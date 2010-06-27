//
//  XAuthTwitterStatusPost.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 10/05/08.
//  Copyright 2010 EY-Office. All rights reserved.
//

#import "XAuthTwitterStatusPost.h"
#import "XAuthTwitterEngine.h"
#import "XAuthInformations.h"
#import "SimpleAlertView.h"
#import "TNLogger.h"


#pragma mark Private properties and methods definition
@interface XAuthTwitterStatusPost ()

@property (nonatomic, retain) XAuthTwitterEngine *twitterEngine;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *message;

- (void) timeOutAction;
- (void) errorAlert:(NSError *)error;
@end


#pragma mark -
@implementation XAuthTwitterStatusPost
@synthesize twitterEngine;
@synthesize username;
@synthesize password;
@synthesize message;
@synthesize delegate;
@synthesize didSuccessSelector;
@synthesize didFailedSelector;


#pragma mark Memory management methods.

- (void)dealloc {
	[twitterEngine release];
	[username release];
	[password release];
	[message release];
	[delegate release];
    [super dealloc];
}


#pragma mark public methods

- (XAuthTwitterStatusPost *) init {
	self = [super init];
	if (self) {
		self.twitterEngine = [[XAuthTwitterEngine alloc] initXAuthWithDelegate:self];
		self.twitterEngine.consumerKey = kOAuthConsumerKey;
		self.twitterEngine.consumerSecret = kOAuthConsumerSecret;
		self.delegate = nil;
		self.didSuccessSelector = nil;
		self.didFailedSelector = nil;
	}
	return self;
}

- (void) setUserName:(NSString *)aUsername password:(NSString *)aPassword {
	self.username = aUsername;
	self.password = aPassword;
}


- (void) postMessage:(NSString *)aMessage timeoutInterval:(NSTimeInterval)timeoutInterval {
	self.message = aMessage;

	// NSLog(@"exchangeAccessTokenForUsername %@", self.username);
	[self.twitterEngine exchangeAccessTokenForUsername:self.username password:self.password];
	if (timeoutInterval != 0.0) {
		[self performSelector:@selector(timeOutAction) withObject:nil afterDelay:timeoutInterval];
	}
}


#pragma mark XAuthTwitterEngineDelegate methods


- (void) sendUpdateToTwitter:(id)anArgument {
	// NSLog(@"sendUpdate: %@", self.message);
	[self.twitterEngine sendUpdate:self.message];
}

- (void) storeCachedTwitterXAuthAccessTokenString: (NSString *)tokenString forUsername:(NSString *)username {
	// NSLog(@"Access token string returned: %@", tokenString);
	[self performSelector:@selector(sendUpdateToTwitter:) withObject:nil afterDelay:0.1];
}

- (NSString *) cachedTwitterXAuthAccessTokenStringForUsername: (NSString *)username {
	// NOT cache the xAuthAccess token
	return nil;
}

- (void) twitterXAuthConnectionDidFailWithError: (NSError *)error {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeOutAction) object:nil];
	TNLog(@"twitterXAuthConnectionDidFailWithError: %@", error);
	[self errorAlert:error];
	
	// callback
	if (self.delegate && self.didFailedSelector) {
		[self.delegate performSelector:self.didFailedSelector withObject:nil afterDelay:0.1];
	}
}


#pragma mark MGTwitterEngineDelegate methods

- (void)requestSucceeded:(NSString *)connectionIdentifier {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeOutAction) object:nil];
	TNLog(@"Twitter request succeeded: %@", connectionIdentifier);
	// callback
	if (self.delegate && self.didSuccessSelector) {
		[self.delegate performSelector:self.didSuccessSelector withObject:nil afterDelay:0.1];
	}
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeOutAction) object:nil];
	TNLog(@"Twitter request failed: %@ with error:%@", connectionIdentifier, error);
	
	[self errorAlert:error];
	// callback
	if (self.delegate && self.didFailedSelector) {
		[self.delegate performSelector:self.didFailedSelector withObject:nil afterDelay:0.1];
	}
}


#pragma mark Private methods

- (void) timeOutAction {
	
	TNLog(@"Twitter request Timout");

	[SimpleAlertView alertWithTitle:@"タイムアウト" message:@"時間をおいてから再度つぶやいて下さい"];
	// callback
	if (self.delegate && self.didFailedSelector) {
		[self.delegate performSelector:self.didFailedSelector withObject:nil afterDelay:0.1];
	}	
}

- (void) errorAlert:(NSError *)error {
	[SimpleAlertView alertWithTitle:[NSString stringWithFormat:@"Twitter送信エラー (%d)", [error code]]
					 message:@"ログイン/パスワードが正しくない、2重投稿、Twitterサービスが止まっているなどが考えられます"];
}


@end
