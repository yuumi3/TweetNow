//
//  MKPlacePinAnnotationView.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 10/04/22.
//  Copyright 2010 EY-Office. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>  


@interface MKPlacePinAnnotationView : MKPinAnnotationView

- (void) addTouchEventProc:(void(^)(int index))eventCallback;


@end
