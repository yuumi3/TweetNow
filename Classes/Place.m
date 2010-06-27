//
//  Place.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/24.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import "Place.h"
#define SQUARE(n) ((n) * (n))


@implementation Place

@synthesize longitude;
@synthesize latitude;
@synthesize name;

- (Place *) initWithLongitude:(float)aLongitude latitude:(float)aLatitude name:(NSString *)aName {
	self = [super init];
	self.longitude = aLongitude;
	self.latitude  = aLatitude;
	self.name      = aName;
	return self;
}

+ (Place *) placeWithLongitude:(float)aLongitude latitude:(float)aLatitude name:(NSString *)aName {
	return [[[Place alloc] initWithLongitude:aLongitude latitude:aLatitude name:aName] autorelease];
}

- (float) squareDistanceFromLongitude:(float)refLongitude latitude:(float)refLatitude {
	return SQUARE(refLongitude - longitude) + SQUARE(refLatitude - latitude);
}

+ (Place *) placeWithString:(NSString *)string {
	NSArray *a = [string componentsSeparatedByString:@"\t"];
	return [Place placeWithLongitude:[[a objectAtIndex:0] floatValue]
				  latitude:          [[a objectAtIndex:1] floatValue]
				  name:              [a objectAtIndex:2]];
}

- (NSString *) toString {
	return [NSString stringWithFormat:@"%f\t%f\t%@", longitude, latitude, name];
}

- (Place *) copy {
	return [Place placeWithLongitude:self.longitude latitude:self.latitude name:self.name.copy];
}

//  Implementation of <MKAnnotation>

- (CLLocationCoordinate2D) coordinate {
    CLLocationCoordinate2D  coordinate;
	
    coordinate.latitude = self.latitude;
    coordinate.longitude = self.longitude;
    
    return coordinate;
}

- (NSString*)title {
	return self.name;
}

- (NSString*)subtitle {
	return @"";
}

@end
