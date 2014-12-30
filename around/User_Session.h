//
//  User_Session.h
//  around
//
//  Created by Benjamin McFerren on 6/3/14.
//  Copyright (c) 2014 DePaul University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User_Session : NSObject

// this is a singlton object that uses thread checking to ensure that it is only invoked once and subsequant requests return the previously instantiated object
+ (instancetype)sharedUserSession;

// array property that holds a fixed amount of the user's answers and the user's questions
- (NSArray *)answers;
- (NSArray *)questions;

// these are public methods accessible from the static object
- (int)findQuestion_ID:(NSDictionary *)matchAnswers;
- (void)addAnswer:(int)questionID :(int)useranswer;
- (NSDictionary *)getUserID;

@end
