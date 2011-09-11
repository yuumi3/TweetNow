//
//  TNLogger.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/25.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import "TNLogger.h"
#import "Config.h"

#define LOG_DB_KEY @"TN_LOG"

void TNLog(NSString *format, ...) {
	va_list args;

	if (! [Config sharedInstance].debug) {
#if TARGET_IPHONE_SIMULATOR
        va_start(args, format);
        NSLog(@"+ %@", [[[NSString alloc] initWithFormat:format arguments:args] autorelease]);
        va_end(args);      
#endif       
        return;
    }

	va_start(args, format);
	NSString *msg = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
    NSLog(@"+ %@", msg);
	
	NSString *log_db = [[NSUserDefaults standardUserDefaults] stringForKey:LOG_DB_KEY];
	if (log_db == nil) log_db = @"";
	NSMutableString *log = [NSMutableString stringWithString:log_db];
	
	NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormat setDateFormat:@"MM/dd HH:mm:ss"];

	[log appendFormat:@"\n-%@ ", [dateFormat stringFromDate:[NSDate date]]];
	[log appendString:msg];
	[[NSUserDefaults standardUserDefaults] setObject:log forKey:LOG_DB_KEY];

	va_end(args);
}

@implementation TNLogger

+ (NSString *) readLogFile {
	return [[NSUserDefaults standardUserDefaults] stringForKey:LOG_DB_KEY];
}
+ (void) deleteLogFile {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:LOG_DB_KEY];
}



@end
