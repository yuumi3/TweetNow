//
//  RegisteredPlaceList.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/25.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import "RegisteredPlaceList.h"
#define DB_VERSION          102     // 場所の種類(kind)を保存
#define DB_VERSION_101		101
#define PLACE_LIST_DB_VERSION @"placeListDbVersion"
#define PLACE_LIST_DB  @"placeListDb"


@implementation RegisteredPlaceList

- (void)load {	
	int dbVersion = [[NSUserDefaults standardUserDefaults] integerForKey:PLACE_LIST_DB_VERSION];
	if (dbVersion == DB_VERSION || dbVersion == DB_VERSION_101) {
		[self fromStringArray:[[NSUserDefaults standardUserDefaults] arrayForKey:PLACE_LIST_DB] defaultKind:PLACE_USER_REGISTERED];
	}
	
	//NSLog(@"load placeDb: %@", list);
}

- (void)save {
	[[NSUserDefaults standardUserDefaults] setInteger:DB_VERSION forKey:PLACE_LIST_DB_VERSION];
	[[NSUserDefaults standardUserDefaults] setObject:[self toStringArray] forKey:PLACE_LIST_DB];
	//NSLog(@"save placeDb: %@", list);
}

- (PlaceList *) nearLongitude:(float)longitude withLatitude:(float)latitude withDelta:(float)delta {
	PlaceList *nears = [PlaceList placeList];

	for (int i = 0; i < [list count]; i++) {
		Place *p = (Place *)list[i];
		if (fabsf(p.longitude - longitude) < delta && fabsf(p.latitude - latitude) < delta) {
			[nears addPlace:p];
		}
	}
	
	[nears sortByDistanceFromLongitude:longitude latitude:latitude];
	return nears;
}


- (PlaceList *) nearLongitude:(float)longitude withLatitude:(float)latitude {
    return [self nearLongitude:longitude withLatitude:latitude withDelta:0.01];
}

- (void) removeAll {
	[list removeAllObjects];
}


+ (RegisteredPlaceList *)sharedInstance {
    static RegisteredPlaceList *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RegisteredPlaceList alloc] init];
    });
    return sharedInstance;
}


@end
