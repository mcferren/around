//
//  User_Session.m
//  around
//
//  Created by Benjamin McFerren on 6/3/14.
//  Copyright (c) 2014 DePaul University. All rights reserved.
//

#import "User_Session.h"
#import "Answer_Factory.h"
#include <stdlib.h>

@interface User_Session ()

@property(strong, nonatomic) NSMutableArray *answers;
@property(strong, nonatomic) NSMutableArray *questions;
@property (copy, nonatomic) NSDictionary *questionNames;

@property (strong, nonatomic) Answer_Factory *answerFactoryObject;

@end

@implementation User_Session

// this method declares the core components needed for the singlton to deliver the correct type of information
- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.answerFactoryObject = [Answer_Factory sharedAnswerFactory];
        
        NSUserDefaults *defaults =
        [NSUserDefaults standardUserDefaults];
        NSArray *storedAnswers = [defaults objectForKey:@"answerobjects"];
        if (storedAnswers) { // mutable means can change
            self.answers = [storedAnswers mutableCopy];
        } else {
            self.answers = [NSMutableArray array];
        }
        
        NSArray *storedQuestions = [defaults objectForKey:@"questionobjects"];
        if (storedQuestions) { // mutable means can change
            self.questions = [storedQuestions mutableCopy];
        } else {
            self.questions = [NSMutableArray array];
        }
        
        NSString *path;
        
        path = [[NSBundle mainBundle] pathForResource:@"questions" ofType:@"plist"];
        self.questionNames = [NSDictionary dictionaryWithContentsOfFile:path];
        
        [self populateAnswers];
        
    }
    return self;
}

// this conditionally checks whether the object has once been created and rreturns the original if it already has
+ (instancetype)sharedUserSession {
    
    static User_Session *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ // also used in threading
        shared = [[self alloc] init];
    });
    return shared;
}


// this utility method prepopulates the answer elements with certain key value pairs
- (void)populateAnswers {
    
    NSDictionary *userAnswers =  [_answerFactoryObject returnAnswersByProfileID:1];
    
    [_answers removeAllObjects];
    
    [_answers insertObject:userAnswers atIndex:0];
    
    [self saveAnswers];
}


// this utility method prepopulates the question elements with certain key value pairs
- (void)populateQuesitons {
    
//    NSMutableDictionary *userAnswers =
//    - (NSDictionary *)returnAnswersByProfileID:(int)profileid
    
    [_answers removeAllObjects];
    
    for(id key in self.questionNames) {
        [self addQuestion:[self.questionNames objectForKey:key]];
    }
}


// this utility method allow to add a answer element at a specific index
- (void)addAnswerAtIndex:(id)item :(int)itemnumber {
    
    [_answers removeObjectAtIndex:itemnumber];
    [_answers insertObject:item atIndex:itemnumber];
    [self saveAnswers];
    
}


// this utility method allow to add a question element at a specific index
- (void)addQuestionAtIndex:(id)item :(int)itemnumber {
    
    [_questions removeObjectAtIndex:itemnumber];
    [_questions insertObject:item atIndex:itemnumber];
    [self saveQuestions];
    
}


// this is a general go to purpose method used to insert the object it recevies into the class property array. It forces intent by invokeng the save method
- (void)addAnswer:(int)questionID :(int)useranswer {
    
    [_answerFactoryObject pushAnswer:questionID
                                    :useranswer
                                    :1];
}


// this is a general go to purpose method used to insert the object it recevies into the class property array. It forces intent by invokeng the save method
- (void)addQuestion:(id)item {
    [_questions insertObject:item atIndex:0];
    [self saveQuestions];
}


// this is a general go to purpose method used to remove the object it recevies into the class property array. It forces intent by invokeng the save method
- (void)removeAnswer:(int)itemnumber {
    [_answers removeObjectAtIndex:itemnumber];
    [self saveAnswers];
}


// this is a general go to purpose method used to remove the object it recevies into the class property array. It forces intent by invokeng the save method
- (void)removeQuestion:(int)itemnumber {
    [_questions removeObjectAtIndex:itemnumber];
    [self saveQuestions];
}


// this method ensures the NSUser Defaults are kept up to date when changing the elements in the class array property
- (void)saveAnswers {
    NSUserDefaults *defaults =
    [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.answers forKey:@"answerobjects"];
    [defaults synchronize];
}


// this method ensures the NSUser Defaults are kept up to date when changing the elements in the class array property
- (void)saveQuestions {
    NSUserDefaults *defaults =
    [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.questions forKey:@"questionobjects"];
    [defaults synchronize];
}


// this is a simple swapping method
- (void)moveAnswerAtIndex:(NSInteger)from toIndex:(NSInteger)to {
    id item = _answers[from];
    [_answers removeObjectAtIndex:from];
    [_answers insertObject:item atIndex:to];
    [self saveAnswers];
}


// this is a simple swapping method
- (void)moveQuestionAtIndex:(NSInteger)from toIndex:(NSInteger)to {
    id item = _questions[from];
    [_questions removeObjectAtIndex:from];
    [_questions insertObject:item atIndex:to];
    [self saveQuestions];
}


// this factory method takes an int as an argument and returns that many answer dictionary objects inside of an array
- (NSMutableArray *)returnAnswers:(int)quantity {
    
    NSMutableArray *returnArray = [NSMutableArray array];
    
    int r;
    
    for(int i = 0; i < quantity; ++i) {
        
        r = arc4random() % (int)[_answers count];
        
        // we are returning a copy
        [returnArray addObject:@{@"profile_ID":_answers[r][@"profile_ID"],
                                 @"name":_answers[r][@"name"],
                                 @"avatar":_answers[r][@"avatar"]
                                 }];
    }
    
    return returnArray;
    
}


// this factory method takes an int as an argument and returns that many question dictionary objects inside of an array
- (NSMutableArray *)returnQuestions:(int)quantity {
    
    NSMutableArray *returnArray = [NSMutableArray array];
    
    int r;
    
    for(int i = 0; i < quantity; ++i) {
        
        r = arc4random() % (int)[_questions count];
        
        // we are returning a copy
        [returnArray addObject:@{@"profile_ID":_questions[r][@"profile_ID"],
                                 @"name":_questions[r][@"name"],
                                 @"avatar":_questions[r][@"avatar"]
                                 }];
    }
    
    return returnArray;
    
}


// this method takes an nsdictionary full of answers that the user's new found match has participated in the past. The method iterats over the keys of this dictionary (the keys are question_id's). The method cross references with the user's nsdictionary full of questions that the user has answered in the past. If it doesn't find a match during a particular iteration , then the method return the question id of that particular elements in the match's dictionary of answered questions
-(int)findQuestion_ID:(NSDictionary *)matchAnswers {
    
    NSMutableArray *questionOptionsPool = [[NSMutableArray alloc] init];
    
    for(id key in matchAnswers) {
        
        // if the friends question# is not found in the user's list, then add it to the elgible array
        if(!_answers[0][key]) {
            [questionOptionsPool addObject:key];
        }
    }
    
    // select randomly from eligible questions in order not to demand that a user must proceed past a particular question in order to further particpate with another user
    if([questionOptionsPool count] > 0) {
        
        int r = arc4random() % (int)[questionOptionsPool count];
        
        return [questionOptionsPool[r] intValue];
        
    } else {
        
        return 0;
    }
}

@end
