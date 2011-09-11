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
@synthesize kind;

- (Place *) initWithLongitude:(float)aLongitude latitude:(float)aLatitude name:(NSString *)aName kind:(int)aKind {
	self = [super init];
	self.longitude = aLongitude;
	self.latitude  = aLatitude;
	self.name      = aName;
    self.kind      = aKind;
	return self;
}

+ (Place *) placeWithLongitude:(float)aLongitude latitude:(float)aLatitude name:(NSString *)aName kind:(int)aKind {
	return [[[Place alloc] initWithLongitude:aLongitude latitude:aLatitude name:aName kind:aKind] autorelease];
}

- (float) squareDistanceFromLongitude:(float)refLongitude latitude:(float)refLatitude {
	return SQUARE(refLongitude - longitude) + SQUARE(refLatitude - latitude);
}

+ (Place *) placeWithString:(NSString *)string defaultKind:(int)kind {
	NSArray *a = [string componentsSeparatedByString:@"\t"];
	return [Place placeWithLongitude:[[a objectAtIndex:0] floatValue]
                            latitude:[[a objectAtIndex:1] floatValue]
                                name:[a objectAtIndex:2]
                                kind:[a count] > 3 ? [[a objectAtIndex:3] intValue] : kind];
}

- (NSString *) toString {
	return [NSString stringWithFormat:@"%f\t%f\t%@\t%d", longitude, latitude, name, kind];
}

- (void) dealloc {
	[name release];
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    Place *copiedPlace = NSCopyObject(self, 0, zone);
    if (copiedPlace) {
        copiedPlace->name = [name copyWithZone:zone];
    }
    return copiedPlace;
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
