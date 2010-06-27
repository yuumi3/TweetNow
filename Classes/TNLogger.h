//
//  TNLogger.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/25.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import <Foundation/Foundation.h>

extern void TNLog(NSString *format, ...);


@interface TNLogger : NSObject {
}
+ (NSString *) readLogFile;
+ (void) deleteLogFile;

@end
