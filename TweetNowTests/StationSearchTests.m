//
//  StationSearchTests.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 10/05/10.
//  Copyright 2010 EY-Office. All rights reserved.
//

#import "StationSearchTests.h"


@implementation StationSearchTests

- (void) testNearLongitude {
	PlaceList *list = [StationSearch nearLongitude:139.670245 withLatitude:35.612152];
	
	STAssertEqualObjects(@"自由が丘", [list nameAtIndex:0], @"1位");
	STAssertEqualObjects(@"都立大学", [list nameAtIndex:1], @"2位");
	STAssertEqualObjects(@"奥沢", [list nameAtIndex:2], @"3位");
	STAssertEqualObjects(@"緑が丘", [list nameAtIndex:3], @"4位");
	STAssertEqualObjects(@"九品仏", [list nameAtIndex:4], @"5位");
}

- (void) testNearLongitudeWithDelta {
	PlaceList *list = [StationSearch nearLongitude:139.670245 withLatitude:35.612152 withDelta:0.01];
    STAssertEquals(5, [list count], @"検索範囲 0.01では5件戻る");
	list = [StationSearch nearLongitude:139.670245 withLatitude:35.612152 withDelta:0.02];
    STAssertEquals(10, [list count], @"検索範囲 0.02では10件戻る");
}

- (void) testSetMaximumResultCount {
	PlaceList *list = [StationSearch nearLongitude:139.670245 withLatitude:35.612152];	
    STAssertEquals(5, [list count], @"デフォルトの検索範囲では5件戻る");
    
    [StationSearch setMaximumResultCount:2];
	list = [StationSearch nearLongitude:139.670245 withLatitude:35.612152];
    STAssertEquals(2, [list count], @"setMaximumResultCountで検索結果数を設定出来る");
}



@end
