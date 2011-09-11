//
//  XAuthTwitterStatusPost.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 10/05/08.
//  Copyright 2010 EY-Office. All rights reserved.
//

#import "TwitterStatusPost.h"
#import "MGTwitterEngine.h"
#import "XAuthInformations.h"
#import "SimpleAlertView.h"
#import "Config.h"
#import "TNLogger.h"


#pragma mark Private properties and methods definition
@interface TwitterStatusPost ()

@property (nonatomic, retain) MGTwitterEngine *twitterEngine;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *message;

- (void) timeOutAction;
- (void) errorAlert:(NSError *)error;
@end


#pragma mark -
@implementation TwitterStatusPost
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

- (TwitterStatusPost *) init {
	self = [super init];
	if (self) {
		self.twitterEngine = [[MGTwitterEngine alloc] initWithDelegate:self];
        [self.twitterEngine setUsesSecureConnection:NO];
        [self.twitterEngine setConsumerKey:kOAuthConsumerKey secret:kOAuthConsumerSecret];
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
    Config *config = [Config sharedInstance];

    if (![config.xAuthToken isEqualToString:@""]) {
        NSLog(@"use xAuthToken %@", self.username);
        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] 
                                      initForReadingWithData:[config.xAuthToken dataUsingEncoding:NSUTF8StringEncoding]];
        OAToken *aToken = [decoder decodeObjectForKey:@"OAToken"];
		[decoder finishDecoding];
		[decoder release];
        if (aToken && [aToken isValid]) {
            [twitterEngine setAccessToken:aToken];
            [self performSelector:@selector(sendUpdateToTwitter:) withObject:nil afterDelay:0.1];
        } else {
            NSLog(@"unfortunately use Password %@", self.username);
            [twitterEngine getXAuthAccessTokenForUsername:username password:password];            
        }
    } else {
        NSLog(@"use Password %@", self.username);
        [twitterEngine getXAuthAccessTokenForUsername:username password:password];
    }
	if (timeoutInterval != 0.0) {
		[self performSelector:@selector(timeOutAction) withObject:nil afterDelay:timeoutInterval];
	}
}



#pragma mark MGTwitterEngineDelegate methods

- (void)accessTokenReceived:(OAToken *)aToken forRequest:(NSString *)connectionIdentifier{
	TNLog(@"Access token received %@", aToken);
    Config *config = [Config sharedInstance];
	NSMutableData *data = [NSMutableData data];

	NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [encoder setOutputFormat:NSPropertyListXMLFormat_v1_0];
	[encoder encodeObject:aToken forKey:@"OAToken"];
	[encoder finishEncoding];

    config.xAuthToken = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    [config save];
	[encoder release];

    [twitterEngine setAccessToken:aToken];
    [self performSelector:@selector(sendUpdateToTwitter:) withObject:nil afterDelay:0.1]; 
}

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

- (void) sendUpdateToTwitter:(id)anArgument {
	NSLog(@"sendUpdate: %@", self.message);
	[self.twitterEngine sendUpdate:self.message];
}

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
