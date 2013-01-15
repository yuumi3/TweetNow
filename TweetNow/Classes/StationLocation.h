//
//  StationLocation.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/20.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    float longitude;
    float latitude;
    char *name;
} LocationInfo;

extern LocationInfo locations[];
extern int locations_length;

@interface StationLocation : NSObject {
}

@end
