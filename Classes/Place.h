//
//  Place.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/24.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface Place : NSObject  <MKAnnotation> {
	float    longitude;
	float    latitude;
	NSString *name;
}
@property (nonatomic) float    longitude;
@property (nonatomic) float    latitude;
@property (nonatomic, retain) NSString *name;

- (Place *) initWithLongitude:(float)aLongitude latitude:(float)aLatitude name:(NSString *)aName;
+ (Place *) placeWithLongitude:(float)aLongitude latitude:(float)aLatitude name:(NSString *)aName;
- (float) squareDistanceFromLongitude:(float)refLongitude latitude:(float)reLatitude;

+ (Place *) placeWithString:(NSString *)string;
- (NSString *) toString;
- (Place *) copy;

@end
