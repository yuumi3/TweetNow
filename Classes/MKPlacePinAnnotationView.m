//
//  MKPlacePinAnnotationView.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 10/04/22.
//  Copyright 2010 EY-Office. All rights reserved.
//

#import "MKPlacePinAnnotationView.h"


@implementation MKPlacePinAnnotationView


- (void) addTouchEventTarget:(id)target action:(SEL)action {
	touchTarget = target;
	touchAction = action;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[touchTarget performSelector:touchAction withObject:[NSNumber numberWithInt:self.tag]];
}

@end
