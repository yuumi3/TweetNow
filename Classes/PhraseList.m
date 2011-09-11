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

static PhraseList *sharedInstanceDelegate = nil;

@interface PhraseList ()

@property (nonatomic, retain) NSMutableArray	*textList;

- (PhraseList *) init;

@end

@implementation PhraseList

@synthesize textList;

- (id) init {	
	self = (PhraseList *)[super init];
    self.textList = [NSMutableArray array];
//    self.textList = [NSMutableArray arrayWithObjects:@"おはよう", @"乗り換え", @"乗り遅れた", @"遅刻か？", @"いい天気 ^^)", nil];
    [self load];
	return self;
}

- (void)load {	
	int dbVersion = [[NSUserDefaults standardUserDefaults] integerForKey:PHRASE_LIST_DB_VERSION];
	if (dbVersion == DB_VERSION) {
		self.textList = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:PHRASE_LIST_DB]];
	}
	
	//NSLog(@"load placeDb: %@", textList);
}

- (void)save {
	[[NSUserDefaults standardUserDefaults] setInteger:DB_VERSION forKey:PHRASE_LIST_DB_VERSION];
	[[NSUserDefaults standardUserDefaults] setObject:textList forKey:PHRASE_LIST_DB];
	//NSLog(@"save placeDb: %@", textList);
}

- (int) count {
    return [textList count];
}

- (NSArray *) list {
    return  textList;
}

- (NSString *) get:(int)index {
    return [textList objectAtIndex:index];
}

- (void) add:(NSString *)phrase {
    [textList insertObject:phrase atIndex:0];
}

- (void) set:(NSString *)phrase atIndex:(int)index {
    [textList replaceObjectAtIndex:index withObject:phrase];
}

- (void) moveFrom:(int)fromIndex to:(int)toIndex {
    NSString *item = [[textList objectAtIndex:fromIndex] retain];
    [textList removeObjectAtIndex:fromIndex];
    [textList insertObject:item atIndex:toIndex];
    [item release];
}

- (void) remove:(int)index {
    [textList removeObjectAtIndex:index];
}



// http://blog.quazie.net/2009/04/sharedinstance-objective-cs-singleton-paradigm/

+ (PhraseList *)sharedInstance {
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
