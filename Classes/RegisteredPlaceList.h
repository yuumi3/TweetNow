//
//  RegisteredPlaceList.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/25.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlaceList.h"


@interface RegisteredPlaceList : PlaceList {
}

+ (RegisteredPlaceList *) sharedInstance;
- (void) load;
- (void) save;
- (PlaceList *) nearLongitude:(float)longitude withLatitude:(float)latitude;
- (void) removeAll;		// method for Testing

@end
