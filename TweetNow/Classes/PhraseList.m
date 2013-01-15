//
//  Phreases.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 11/05/08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhraseList.h"

#define DB_VERSION 101
#define PHRASE_LIST_DB_VERSION @"phraseListDbVersion"
#define PHRASE_LIST_DB  @"phraseListDb"


@interface PhraseList ()

@property (nonatomic, retain) NSMutableArray	*textList;

- (PhraseList *) init;

@end

@implementation PhraseList

@synthesize textList;

- (id) init {	
	self = (PhraseList *)[super init];
    self.textList = [NSMutableArray array];
    // self.textList = [NSMutableArray arrayWithObjects:@"おはよう", @"乗り換え", @"乗り遅れた", @"遅刻か？", @"いい天気 ^^)", nil];
    [self load];
	return self;
}

- (void)load {	
	int dbVersion = [[NSUserDefaults standardUserDefaults] integerForKey:PHRASE_LIST_DB_VERSION];
	if (dbVersion == DB_VERSION) {
		self.textList = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:PHRASE_LIST_DB]];
	}
}

- (void)save {
	[[NSUserDefaults standardUserDefaults] setInteger:DB_VERSION forKey:PHRASE_LIST_DB_VERSION];
	[[NSUserDefaults standardUserDefaults] setObject:textList forKey:PHRASE_LIST_DB];
}

- (int) count {
    return [textList count];
}

- (NSArray *) list {
    return  textList;
}

- (NSString *) get:(int)index {
    return textList[index];
}

- (void) add:(NSString *)phrase {
    [textList insertObject:phrase atIndex:0];
}

- (void) set:(NSString *)phrase atIndex:(int)index {
    [textList replaceObjectAtIndex:index withObject:phrase];
}

- (void) moveFrom:(int)fromIndex to:(int)toIndex {
    NSString *item = textList[fromIndex];
    [textList removeObjectAtIndex:fromIndex];
    [textList insertObject:item atIndex:toIndex];
}

- (void) remove:(int)index {
    [textList removeObjectAtIndex:index];
}


+ (PhraseList *)sharedInstance {
    static PhraseList *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PhraseList alloc] init];
    });
    return sharedInstance;
}



@end
