//
//  MKPlacePinAnnotationView.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 10/04/22.
//  Copyright 2010 EY-Office. All rights reserved.
//

#import "MKPlacePinAnnotationView.h"

@interface MKPlacePinAnnotationView ()
@property(copy, nonatomic) void(^eventCallback)(int index);
@end


@implementation MKPlacePinAnnotationView


- (void) addTouchEventProc:(void(^)(int index))eventCallback {
    _eventCallback = eventCallback;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _eventCallback(self.tag);
}

@end
