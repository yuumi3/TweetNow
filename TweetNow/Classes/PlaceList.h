//
//  PlaceList.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/24.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Place.h"

typedef struct {
	float longitude;
	float latitude;
} Location;


@interface PlaceList : NSObject {
	NSMutableArray *list;
}

+ (PlaceList *) placeList;
- (PlaceList *) init;

- (void) addPlace:(Place *)place;
- (void) addCopyOfPlace:(Place *)place;
- (void) addPlaceList:(PlaceList *)placeList;
- (void) sortByDistanceFromLongitude:(float)refLongitude latitude:(float)refLatitude;

- (int) count;
- (float)longitudeAtIndex:(int)index;
- (float)latitudeAtIndex:(int)index;
- (NSString *)nameAtIndex:(int)index;
- (int)kindAtIndex:(int)index;
- (Place *) placeAtIndex:(int)index;
- (void)removeAtIndex:(int)index;
- (int) indexOfName:(NSString *)aName;
- (Location *) distanceOfPlaceListWithLongitude:(float)aLongitude latitude:(float)aLatitude;
- (void) movePlaceAtIndex:(int)fromIndex toIndex:(int)toIndex;
- (void) truncateCount:(int)newSize;

- (NSArray *) toStringArray;
- (void) fromStringArray:(NSArray *)array defaultKind:(int)kind;

@end
