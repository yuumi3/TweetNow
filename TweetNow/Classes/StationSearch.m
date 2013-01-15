//
//  StationSearch.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/20.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import "StationSearch.h"
#import "StationLocation.h"
#define TEMPORARY_LIST_SIZE 500
static int maximumResultCount = 50;

@implementation StationSearch

+ (void) setMaximumResultCount:(int)count {
    maximumResultCount = count;
}

+ (PlaceList *) nearLongitude:(float)longitude withLatitude:(float)latitude withDelta:(float)delta {
	LocationInfo *near[TEMPORARY_LIST_SIZE];

    
    float lon_low = longitude - delta;
    float lon_hight = longitude + delta;
    int n_near = 0;

    int i;
    
    // 緯度で選択
    for (i = 0; i < locations_length && n_near < TEMPORARY_LIST_SIZE; i++) {
        if (locations[i].longitude >= lon_low && locations[i].longitude <= lon_hight) {
            near[n_near++] = &locations[i];
        }
    }
    //NSLog(@"n_near %d", n_near);
    
    // 経度で不要データを除去
    for (i = 0; i < n_near; i++) {
        if (fabsf(near[i]->latitude - latitude) >= delta) {
            near[i] = NULL;
        }
    }

	// PlaceListデータに詰め替え
    PlaceList *answer = [PlaceList placeList];
    for (i = 0; i < n_near; i++) {
        if (near[i]) {
            Place *p = [Place placeWithLongitude:near[i]->longitude
                                        latitude:near[i]->latitude
                                            name:[NSString stringWithCString:near[i]->name encoding:NSUTF8StringEncoding]
                                            kind:PLACE_STATION];
 			[answer addPlace:p];
        }
    }
	// 近い順にソート
	[answer sortByDistanceFromLongitude:longitude latitude:latitude];
    [answer truncateCount:maximumResultCount];
	return answer;
}


+ (PlaceList *) nearLongitude:(float)longitude withLatitude:(float)latitude {
    return [StationSearch nearLongitude:longitude withLatitude:latitude withDelta:0.01];
}

@end
