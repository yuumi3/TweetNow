//
//  Config.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/23.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Config : NSObject
@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, strong) NSString *postfix;
@property (nonatomic, strong) NSString *hashTag;
@property (nonatomic)         BOOL     debug;
@property (nonatomic)         int      dbVersion;


+ (Config *)sharedInstance;
- (void)load;
- (void)save;

@end
