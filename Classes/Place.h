//
//  Place.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/24.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#define PLACE_STATION           1
#define PLACE_USER_REGISTERED   2

@interface Place : NSObject  <MKAnnotation, NSCopying> {
	float    longitude;
	float    latitude;
	NSString *name;
    int      kind;
}
@property (nonatomic) float    longitude;
@property (nonatomic) float    latitude;
@property (nonatomic, retain)  NSString *name;
@property (nonatomic) int      kind;

- (Place *) initWithLongitude:(float)aLongitude latitude:(float)aLatitude name:(NSString *)aName kind:(int)aKind;
+ (Place *) placeWithLongitude:(float)aLongitude latitude:(float)aLatitude name:(NSString *)aName kind:(int)aKind;
- (float) squareDistanceFromLongitude:(float)refLongitude latitude:(float)reLatitude;

+ (Place *) placeWithString:(NSString *)string defaultKind:(int)kind;
- (NSString *) toString;

@end
