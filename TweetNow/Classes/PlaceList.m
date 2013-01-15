//
//  PlaceList.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/24.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import "PlaceList.h"


@interface PlaceList(Private)

- (NSMutableArray *) list;

@end


@implementation PlaceList


NSInteger locationCompare(Place *p1, Place *p2, Location *refrence) {
	float d1 = [p1 squareDistanceFromLongitude:refrence->longitude latitude:refrence->latitude];
	float d2 = [p2 squareDistanceFromLongitude:refrence->longitude latitude:refrence->latitude];
	
	if (d1 < d2)
        return NSOrderedAscending;
    else if (d1 > d2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

- (PlaceList *) init {
	self = [super init];
	list = [[NSMutableArray alloc] initWithCapacity:10];
    // [list addObject:[Place placeWithLongitude:139.670245 latitude:35.612152 name:@"TEST" kind:PLACE_USER_REGISTERED]];
	return self;
}

- (NSMutableArray *) list {
	return list;
}

+ (PlaceList *) placeList {
	return [[PlaceList alloc] init]; 
}

- (void) addPlace:(Place *)place {
	[list addObject:place];
}

- (void) addCopyOfPlace:(Place *)place {
    Place *copiedPlace = [place copy];
	[list addObject:copiedPlace];
}

- (void) addPlaceList:(PlaceList *)placeList {
	[list addObjectsFromArray:[placeList list]];
}

- (void) sortByDistanceFromLongitude:(float)refLongitude latitude:(float)refLatitude {
	Location refrence;
	refrence.longitude = refLongitude;
	refrence.latitude  = refLatitude;
	
	[list sortUsingFunction:(NSInteger (*)(id, id, void *))locationCompare context:&refrence];
}

- (int) count {
	return [list count];
}

- (float)longitudeAtIndex:(int)index {
	return [list[index] longitude];
}

- (float)latitudeAtIndex:(int)index {
	return [list[index] latitude];
}

- (NSString *)nameAtIndex:(int)index {
	return [list[index] name];
}

- (int)kindAtIndex:(int)index {
    return [list[index] kind];
}

- (Place *) placeAtIndex:(int)index {
	return list[index];
}

- (void)removeAtIndex:(int)index {
	[list removeObjectAtIndex:index];
}

- (int)indexOfName:(NSString *)aName {
	for (int i = 0; i < [list count]; i++) {
		if ([aName isEqualToString:[list[i] name]]) {
			return  i;
		}
	}
	return  -1;
}

- (void) movePlaceAtIndex:(int)fromIndex toIndex:(int)toIndex {
    Place *item = list[fromIndex];
    [list removeObjectAtIndex:fromIndex];
    [list insertObject:item atIndex:toIndex];
}

- (Location *) distanceOfPlaceListWithLongitude:(float)aLongitude latitude:(float)aLatitude {
	static Location distance;
	Location max, min;
	
	max.longitude = min.longitude = aLongitude;
	max.latitude  = min.latitude  = aLatitude;
	for (int i = 0; i < [list count]; i++) {
		float longitude = [list[i] longitude];
		float latitude = [list[i] latitude];
		if (longitude > max.longitude) max.longitude = longitude;
		if (longitude < min.longitude) min.longitude = longitude;
		if (latitude  > max.latitude)  max.latitude  = latitude;
		if (latitude  < min.latitude)  min.latitude  = latitude;
	}
	distance.longitude = max.longitude - min.longitude;
	distance.latitude  = max.latitude  - min.latitude;
	
	return &distance;
}

- (void) truncateCount:(int)newSize {
    if ([list count] > newSize) {
        [list removeObjectsInRange:NSMakeRange(newSize, [list count] - newSize)];
    }
}

- (NSArray *) toStringArray {
	NSMutableArray *stringArray = [NSMutableArray arrayWithCapacity:20];
	for (int i = 0; i < [list count]; i++) {
		[stringArray addObject:[list[i] toString]];
	}
	return (NSArray *)stringArray;
}

- (void) fromStringArray:(NSArray *)array defaultKind:(int)kind {
	[list removeAllObjects];
	for (int i = 0; i < [array count]; i++) {
		[self addPlace:[Place placeWithString:array[i] defaultKind:kind]];
	}
}


@end
