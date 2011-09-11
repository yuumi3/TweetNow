//
//  /
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/26.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import "PlaceListTests.h"


@implementation PlaceListTests

- (void) testAddPlace {
    PlaceList *list = [PlaceList placeList];
	[list addPlace:[Place placeWithLongitude:139.668664 latitude:35.607224 name:@"自由が丘" kind:PLACE_STATION]];
	
	STAssertEquals(1, [list count], @"add後countが増えている");
	STAssertEquals((float)139.668664, [list longitudeAtIndex:0], @"緯度が取得できる");
	STAssertEquals((float)35.607224, [list latitudeAtIndex:0], @"経度が取得できる");
	STAssertEquals(@"自由が丘", [list nameAtIndex:0], @"名前が取得できる");
	STAssertEquals(PLACE_STATION, [list kindAtIndex:0], @"種類が取得出来る");
}

- (void) testRemoveAtIndex {
    PlaceList *list = [PlaceList placeList];
	[list addPlace:[Place placeWithLongitude:139.672355 latitude:35.603947 name:@"奥沢" kind:PLACE_STATION]];
	[list addPlace:[Place placeWithLongitude:139.668664 latitude:35.607224 name:@"自由が丘" kind:PLACE_STATION]];
	[list addPlace:[Place placeWithLongitude:139.660992 latitude:35.60538 name:@"九品仏" kind:PLACE_STATION]];
	
	[list removeAtIndex:1];
	STAssertEquals(2, [list count], @"remove後countが減っている");
	STAssertEquals(@"九品仏", [list nameAtIndex:1], @"index後の要素が前に移動している");
}

- (void) testIndexOfName {
    PlaceList *list = [PlaceList placeList];
	[list addPlace:[Place placeWithLongitude:139.672355 latitude:35.603947 name:@"奥沢" kind:PLACE_STATION]];
	[list addPlace:[Place placeWithLongitude:139.668664 latitude:35.607224 name:@"自由が丘" kind:PLACE_STATION]];
	[list addPlace:[Place placeWithLongitude:139.660992 latitude:35.60538 name:@"九品仏" kind:PLACE_STATION]];

	STAssertEquals(2, [list indexOfName:@"九品仏"], @"nameが存在する場合をindex戻す");
	STAssertEquals(-1, [list indexOfName:@"都立大学"], @"nameが存在しない場合-1を戻す");
}

- (void) testMovePlaceAtIndex {
    PlaceList *list = [PlaceList placeList];
	[list addPlace:[Place placeWithLongitude:139.672355 latitude:35.603947 name:@"奥沢" kind:PLACE_STATION]];
	[list addPlace:[Place placeWithLongitude:139.668664 latitude:35.607224 name:@"自由が丘" kind:PLACE_STATION]];
	[list addPlace:[Place placeWithLongitude:139.660992 latitude:35.60538 name:@"九品仏" kind:PLACE_STATION]];
	
	[list movePlaceAtIndex:2 toIndex:0];
	STAssertEquals(@"九品仏", [list nameAtIndex:0], @"2番目の値が0番目に移動している");    
	STAssertEquals(@"奥沢", [list nameAtIndex:1], @"それにともない、0番目の値が1番目に移動");    
	STAssertEquals(@"自由が丘", [list nameAtIndex:2], @"それにともない、1番目の値が2番目に移動");    
}

- (void) testTruncateCount {
    PlaceList *list = [PlaceList placeList];
	[list addPlace:[Place placeWithLongitude:139.672355 latitude:35.603947 name:@"奥沢" kind:PLACE_STATION]];
	[list addPlace:[Place placeWithLongitude:139.668664 latitude:35.607224 name:@"自由が丘" kind:PLACE_STATION]];
	[list addPlace:[Place placeWithLongitude:139.660992 latitude:35.60538 name:@"九品仏" kind:PLACE_STATION]];
	[list addPlace:[Place placeWithLongitude:139.660992 latitude:35.60538 name:@"九品仏2" kind:PLACE_STATION]];
    
    [list truncateCount:2];
	STAssertEquals(2, [list count], @"リストの大きさが指定したsizeに成っている");

    [list truncateCount:3];
	STAssertEquals(2, [list count], @"指定したsizeがリストより大きいときは影響なし");
    
}

- (void) testAddCopyOfPlace {
    PlaceList *list = [PlaceList placeList];
	Place *place = [Place placeWithLongitude:139.668664 latitude:35.607224 name:@"自由が丘" kind:PLACE_USER_REGISTERED];
	[list addCopyOfPlace:place];
	place.name = @"九品仏";
	[list addCopyOfPlace:place];
	
	STAssertEquals(2, [list count], @"add後countが増えている");
	STAssertEquals((float)139.668664, [list longitudeAtIndex:0], @"緯度が取得できる");
	STAssertEquals((float)35.607224, [list latitudeAtIndex:0], @"経度が取得できる");
	STAssertEquals(@"自由が丘", [list nameAtIndex:0], @"名前が取得できる(index:0)");
	STAssertEquals(@"九品仏", [list nameAtIndex:1], @"名前が取得できる(index:1)");
	STAssertEquals(PLACE_USER_REGISTERED, [list kindAtIndex:0], @"種類が取得できる");
}

- (void) testAddPlaceList {
    PlaceList *list1 = [PlaceList placeList];
	[list1 addPlace:[Place placeWithLongitude:139.672355 latitude:35.603947 name:@"奥沢" kind:PLACE_STATION]];
	[list1 addPlace:[Place placeWithLongitude:139.668664 latitude:35.607224 name:@"自由が丘" kind:PLACE_STATION]];
	[list1 addPlace:[Place placeWithLongitude:139.660992 latitude:35.60538 name:@"九品仏" kind:PLACE_STATION]];
	
    PlaceList *list2 = [PlaceList placeList];
	[list2 addPlace:[Place placeWithLongitude:139.667356 latitude:35.596815 name:@"田園調布" kind:PLACE_STATION]];
	[list2 addPlace:[Place placeWithLongitude:139.676393 latitude:35.617835 name:@"都立大学" kind:PLACE_STATION]];
	
	[list1 addPlaceList:list2];
	STAssertEquals(5, [list1 count], @"countはlist1,2の長さの和になっている");
	STAssertEquals(@"奥沢", [list1 nameAtIndex:0], @"1");
	STAssertEquals(@"自由が丘", [list1 nameAtIndex:1], @"2");
	STAssertEquals(@"九品仏", [list1 nameAtIndex:2], @"3");
	STAssertEquals(@"田園調布", [list1 nameAtIndex:3], @"4");
	STAssertEquals(@"都立大学", [list1 nameAtIndex:4], @"5");
}

- (void) testSortByDistanceFromLongitude {
    PlaceList *list = [PlaceList placeList];
	[list addPlace:[Place placeWithLongitude:139.672355 latitude:35.603947 name:@"奥沢" kind:PLACE_STATION]];
	[list addPlace:[Place placeWithLongitude:139.668664 latitude:35.607224 name:@"自由が丘" kind:PLACE_STATION]];
	[list addPlace:[Place placeWithLongitude:139.667356 latitude:35.596815 name:@"田園調布" kind:PLACE_STATION]];
	[list addPlace:[Place placeWithLongitude:139.676393 latitude:35.617835 name:@"都立大学" kind:PLACE_STATION]];
	[list addPlace:[Place placeWithLongitude:139.660992 latitude:35.60538 name:@"九品仏" kind:PLACE_STATION]];
	
	[list sortByDistanceFromLongitude:139.670245 latitude:35.612152];
	STAssertEquals(@"自由が丘", [list nameAtIndex:0], @"1位");
	STAssertEquals(@"都立大学", [list nameAtIndex:1], @"2位");
	STAssertEquals(@"奥沢", [list nameAtIndex:2], @"3位");
	STAssertEquals(@"九品仏", [list nameAtIndex:3], @"4位");
	STAssertEquals(@"田園調布", [list nameAtIndex:4], @"5位");
}

- (void) testToSTringArrayAndFromStringArray {
    PlaceList *list = [PlaceList placeList];
	[list addPlace:[Place placeWithLongitude:139.672355 latitude:35.603947 name:@"奥沢" kind:PLACE_STATION]];
	[list addPlace:[Place placeWithLongitude:139.668664 latitude:35.607224 name:@"自由が丘" kind:PLACE_USER_REGISTERED]];
	[list addPlace:[Place placeWithLongitude:139.667356 latitude:35.596815 name:@"田園調布" kind:PLACE_STATION]];
	
	NSArray *strings = [list toStringArray];
	PlaceList *list2 = [PlaceList placeList];
	[list2 fromStringArray:strings defaultKind:PLACE_STATION];
	STAssertEquals(3, (int)[list2 count], @"fromStringArrayの結果も同じ長さ");
	STAssertEquals(@"奥沢", [list nameAtIndex:0], @"1番目の要素のnameが復元されている");
	STAssertEquals(@"自由が丘", [list nameAtIndex:1], @"2番目の要素のnameが復元されている");
	STAssertEquals(@"田園調布", [list nameAtIndex:2], @"3番目の要素のnameが復元されている");
	STAssertEquals((float)139.672355, [list longitudeAtIndex:0], @"1番目の要素のlongitudeが復元されている");
	STAssertEquals((float)35.603947, [list latitudeAtIndex:0], @"1番目の要素のlatitudeが復元されている");
	STAssertEquals(PLACE_USER_REGISTERED, [list kindAtIndex:1], @"2番目の要素のkindが復元されている");
	STAssertEquals(PLACE_STATION, [list kindAtIndex:2], @"3番目の要素のkindが復元されている");
}

- (void) testDistanceOfPlaceListWithLongitude {
    PlaceList *list = [PlaceList placeList];
	[list addPlace:[Place placeWithLongitude:139.672355 latitude:35.603947 name:@"奥沢" kind:PLACE_STATION]];
	[list addPlace:[Place placeWithLongitude:139.668664 latitude:35.607224 name:@"自由が丘" kind:PLACE_STATION]];
	[list addPlace:[Place placeWithLongitude:139.660992 latitude:35.60538 name:@"九品仏" kind:PLACE_STATION]];
	Location *loc = [list distanceOfPlaceListWithLongitude:139.676393 latitude:35.617835]; // @"都立大学"
	
	STAssertEqualsWithAccuracy(139.676393 - 139.660992, 0.00001, loc->longitude, @"longitudeの差が計算される");
	STAssertEqualsWithAccuracy(35.617835 - 35.603947,   0.00001, loc->latitude, @"latitudeの差が計算される");
}

@end
