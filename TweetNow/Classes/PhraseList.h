//
//  Phreases.h
//  TweetNow
//
//  Created by Yuumi Yoshida on 11/05/08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PhraseList : NSObject {
  @private
    NSMutableArray  *textList;
}

+ (PhraseList *) sharedInstance;
- (int) count;
- (NSArray *) list;
- (NSString *) get:(int)index;
- (void) add:(NSString *)phrase;
- (void) set:(NSString *)phrase atIndex:(int)index;
- (void) moveFrom:(int)fromIndex to:(int)toIndex;
- (void) remove:(int)index;
- (void) load;
- (void) save;


@end
