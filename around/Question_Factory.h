//
//  Question_Factory.h
//  around
//
//  Created by Benjamin McFerren on 6/4/14.
//  Copyright (c) 2014 DePaul University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Question_Factory : NSObject

// this is a singlton object that uses thread checking to ensure that it is only invoked once and subsequant requests return the previously instantiated object
+ (instancetype)sharedQuestionFactory;

// array property that holds a fixed amount of answers
- (NSArray *)questions;

// these are public methods accessible from the static object
- (NSMutableArray *)returnQuestionsByProfileID:(int)profileid;
- (NSDictionary *)returnQuestionByQuestionID:(int)questionid;
- (void)addQuestion:(id)item;

@end
