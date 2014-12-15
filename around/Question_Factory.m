//
//  Question_Factory.m
//  around
//
//  Created by Benjamin McFerren on 6/4/14.
//  Copyright (c) 2014 DePaul University. All rights reserved.
//

#import "Question_Factory.h"
#include <stdlib.h>

@interface Question_Factory ()

@property(strong, nonatomic) NSMutableArray *questions;
@property (copy, nonatomic) NSDictionary *names;

@end

@implementation Question_Factory

// this method declares the core components needed for the singlton to deliver the correct type of information
- (instancetype)init {
    self = [super init];
    if (self) {
        NSUserDefaults *defaults =
        [NSUserDefaults standardUserDefaults];
        NSArray *storedQuestions = [defaults objectForKey:@"questionobjects"];
        if (storedQuestions) { // mutable means can change
            self.questions = [storedQuestions mutableCopy];
        } else {
            self.questions = [NSMutableArray array];
        }
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"questions" ofType:@"plist"];
        self.names = [NSDictionary dictionaryWithContentsOfFile:path];
        
        [self populateQuestions];
        
    }
    return self;
}

// this conditionally checks whether the object has once been created and rreturns the original if it already has
+ (instancetype)sharedQuestionFactory {
    
    static Question_Factory *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ // also used in threading
        shared = [[self alloc] init];
    });
    return shared;
}


// this utility method prepopulates the question elements with certain key value pairs
- (void)populateQuestions {
    [_questions removeAllObjects];
    
    for(id key in self.names) {
        [self addQuestion:[self.names objectForKey:key]];
    }
    
    NSLog(@"_question %@", _questions);
}


// this utility method allow to add a question element at a specific index
- (void)addQuestionAtIndex:(id)item :(int)itemnumber {
    
    [_questions removeObjectAtIndex:itemnumber];
    [_questions insertObject:item atIndex:itemnumber];
    [self saveQuestions];
    
}

// this is a general go to purpose method used to insert the object it recevies into the class property array. It forces intent by invokeng the save method
- (void)addQuestion:(id)item {
    NSLog(@"BEFORE _questions %@", _questions);
    [_questions insertObject:item atIndex:0];
    [self saveQuestions];
    NSLog(@"AFTER _questions %@", _questions);
}


// this is a general go to purpose method used to remove the object it recevies into the class property array. It forces intent by invokeng the save method
- (void)removeQuestion:(int)itemnumber {
    [_questions removeObjectAtIndex:itemnumber];
    [self saveQuestions];
}

// this method ensures the NSUser Defaults are kept up to date when changing the elements in the class array property
- (void)saveQuestions {
    NSUserDefaults *defaults =
    [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.questions forKey:@"questionobjects"];
    [defaults synchronize];
}

// this is a simple swapping method
- (void)moveQuestionAtIndex:(NSInteger)from toIndex:(NSInteger)to {
    id item = _questions[from];
    [_questions removeObjectAtIndex:from];
    [_questions insertObject:item atIndex:to];
    [self saveQuestions];
}

// this is a simple lookup of all questions created by the profileid - returns array
- (NSMutableArray *)returnQuestionsByProfileID:(int)profileid {
    
    NSMutableArray *returnQuestionSet = [[NSMutableArray alloc] init];
    
    
    for(id key in _questions) {
        if([key[@"author_id"] intValue] == profileid) {
            [returnQuestionSet addObject:key];
        }
    }
    
    return returnQuestionSet;
}

// this is a simple lookup of particular question by its id - returns dictionary
- (NSDictionary *)returnQuestionByQuestionID:(int)questionid {
    
    for(id key in _questions) {
        if(questionid == [key[@"question_id"] intValue]) {
            return key;
        }
    }
    
    return nil;
}

@end
