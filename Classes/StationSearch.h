//
//  StationSearch.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/20.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlaceList.h"

@interface StationSearch : NSObject {
}
+ (PlaceList *) nearLongitude:(float)longitude withLatitude:(float)latitude withDelta:(float)delta;
+ (PlaceList *) nearLongitude:(float)longitude withLatitude:(float)latitude;
+ (void) setMaximumResultCount:(int)count;

@end