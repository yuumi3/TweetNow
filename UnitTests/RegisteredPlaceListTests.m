//
//  RegisteredPlaceListTests.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/26.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import "RegisteredPlaceListTests.h"


@implementation RegisteredPlaceListTests


- (void) testSaveAndLoad {
	RegisteredPlaceList *list = [RegisteredPlaceList sharedInstance];
	[list removeAll];
	[list addPlace:[Place placeWithLongitude:139.672355 latitude:35.603947 name:@"奥沢"]];
	[list addPlace:[Place placeWithLongitude:139.668664 latitude:35.607224 name:@"自由が丘"]];
	[list addPlace:[Place placeWithLongitude:139.676393 latitude:35.617835 name:@"都立大学"]];
	
	[list save];
	[list removeAll];
	STAssertEquals(0, [list count], @"全削除したので0");
	
	[list load];
	STAssertEquals(3, [list count], @"読み込んだので元の長さ");
	STAssertEqualObjects(@"奥沢", [list nameAtIndex:0], @"1番目の要素のnameが復元されている");
	STAssertEqualObjects(@"自由が丘", [list nameAtIndex:1], @"2番目の要素のnameが復元されている");
	STAssertEqualObjects(@"都立大学", [list nameAtIndex:2], @"3番目の要素のnameが復元されている");
	STAssertEquals((float)139.672355, [list longitudeAtIndex:0], @"1番目の要素のlongitudeが復元されている");
	STAssertEquals((float)35.603947, [list latitudeAtIndex:0], @"1番目の要素のlatitudeが復元されている");
}


- (void) testNearLongitude {
	RegisteredPlaceList *list = [RegisteredPlaceList sharedInstance];

	[list removeAll];
	[list addPlace:[Place placeWithLongitude:139.672355 latitude:35.603947 name:@"奥沢"]];
	[list addPlace:[Place placeWithLongitude:139.668664 latitude:35.607224 name:@"自由が丘"]];
	[list addPlace:[Place placeWithLongitude:139.676393 latitude:35.617835 name:@"都立大学"]];
	[list addPlace:[Place placeWithLongitude:139.667356 latitude:35.596815 name:@"田園調布"]];

	PlaceList *nears = [list nearLongitude:139.670245 withLatitude:35.612152];
	STAssertEquals(3, [nears count], @"近い候補は3つ");
	STAssertEqualObjects(@"自由が丘", [nears nameAtIndex:0], @"1番目に近い");
	STAssertEqualObjects(@"都立大学", [nears nameAtIndex:1], @"2番目に近い");
	STAssertEqualObjects(@"奥沢", [nears nameAtIndex:2], @"3番目に近い");
}


/*
 - (void)load;
 - (void)save;
 - (PlaceList *) nearLongitude:(float)longitude withLatitude:(float)latitude;
*/

@end
