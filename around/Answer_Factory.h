//
//  Answer_Factory.h
//  around
//
//  Created by Benjamin McFerren on 6/3/14.
//  Copyright (c) 2014 DePaul University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Answer_Factory : NSObject

// this is a singlton object that uses thread checking to ensure that it is only invoked once and subsequant requests return the previously instantiated object
+ (instancetype)sharedAnswerFactory;

// array property that holds a fixed amount of answers
- (NSArray *)answers;

// these are public methods accessible from the static object
- (void)pushAnswer:(int)questionid :(int)answersubmitted :(int)userid;
- (NSDictionary *)returnAnswersByProfileID:(int)profileid;
- (NSMutableArray *)returnAnswersArrayByProfileID:(int)profileid;

@end
