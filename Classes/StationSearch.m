//
//  StationSearch.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/20.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import "StationSearch.h"
#import "StationLocation.h"


@implementation StationSearch

+ (PlaceList *) nearLongitude:(float)longitude withLatitude:(float)latitude {
	LocationInfo *near[500];

    
    float lon_low = longitude - 0.01;
    float lon_hight = longitude + 0.01;
    int n_near = 0;

    int i;
    
    // 緯度で選択
    for (i = 0; i < locations_length; i++) {
        if (locations[i].longitude >= lon_low && locations[i].longitude <= lon_hight) {
            near[n_near++] = &locations[i];
        }
    }
    //NSLog(@"n_near %d", n_near);
    
    // 経度で不要データを除去
    for (i = 0; i < n_near; i++) {
        if (fabsf(near[i]->latitude - latitude) >= 0.01) {
            near[i] = NULL;
        }
    }

	// PlaceListデータに詰め替え
    PlaceList *answer = [PlaceList placeList];
    for (i = 0; i < n_near; i++) {
        if (near[i]) {
			[answer addPlace:[Place placeWithLongitude:near[i]->longitude latitude:near[i]->latitude
							name:[NSString stringWithCString:near[i]->name encoding:NSUTF8StringEncoding]]];
        }
    }
	// 近い順にソート
	[answer sortByDistanceFromLongitude:longitude latitude:latitude];
	return answer;
}

@end
