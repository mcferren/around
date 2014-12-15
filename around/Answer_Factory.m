//
//  Answer_Factory.m
//  around
//
//  Created by Benjamin McFerren on 6/3/14.
//  Copyright (c) 2014 DePaul University. All rights reserved.
//

#import "Answer_Factory.h"
#import "Question_Factory.h"
#include <stdlib.h>

@interface Answer_Factory ()

@property(strong, nonatomic) NSMutableArray *answers;
@property (copy, nonatomic) NSDictionary *names;

@property (strong, nonatomic) Question_Factory *questionFactoryObject;

@end

@implementation Answer_Factory

// this method declares the core components needed for the singlton to deliver the correct type of information
- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.questionFactoryObject = [Question_Factory sharedQuestionFactory];
        
        NSUserDefaults *defaults =
        [NSUserDefaults standardUserDefaults];
        NSArray *storedAnswers = [defaults objectForKey:@"answerobjects"];
        if (storedAnswers) { // mutable means can change
            self.answers = [storedAnswers mutableCopy];
        } else {
            self.answers = [NSMutableArray array];
        }
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"answers" ofType:@"plist"];
        self.names = [NSDictionary dictionaryWithContentsOfFile:path];
        
        [self populateAnswers];
        
    }
    return self;
}

// this conditionally checks whether the object has once been created and rreturns the original if it already has
+ (instancetype)sharedAnswerFactory {
    
    static Answer_Factory *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ // also used in threading
        shared = [[self alloc] init];
    });
    return shared;
}


// this utility method prepopulates the answer elements with certain key value pairs
- (void)populateAnswers {
    [_answers removeAllObjects];
    
    for(id key in self.names) {
        [self addAnswer:[self.names objectForKey:key]];
    }
    
//    NSLog(@"^^^_answers %@", _answers[0]);
}


// this utility method allow to add a answer element at a specific index
- (void)addAnswerAtIndex:(id)item :(int)itemnumber {
    
    [_answers removeObjectAtIndex:itemnumber];
    [_answers insertObject:item atIndex:itemnumber];
    [self saveAnswers];
    
}

// this is a general go to purpose method used to insert the object it recevies into the class property array. It forces intent by invokeng the save method
- (void)addAnswer:(id)item {
    [_answers insertObject:item atIndex:0];
    [self saveAnswers];
}


// this is a general go to purpose method used to remove the object it recevies into the class property array. It forces intent by invokeng the save method
- (void)removeAnswer:(int)itemnumber {
    [_answers removeObjectAtIndex:itemnumber];
    [self saveAnswers];
}

// this method ensures the NSUser Defaults are kept up to date when changing the elements in the class array property
- (void)saveAnswers {
    NSUserDefaults *defaults =
    [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.answers forKey:@"answerobjects"];
    [defaults synchronize];
}

// this is a simple swapping method
- (void)moveAnswerAtIndex:(NSInteger)from toIndex:(NSInteger)to {
    id item = _answers[from];
    [_answers removeObjectAtIndex:from];
    [_answers insertObject:item atIndex:to];
    [self saveAnswers];
}


// this method accepts a profile id and returns all her answer objects in a dictionary
- (NSDictionary *)returnAnswersByProfileID:(int)profileid {
    
//    NSLog(@"_answers[0] %@", _answers[0]);
    
    NSDictionary *returnAnswerSet = _answers[0][[NSString stringWithFormat:@"%d",profileid]];    
    
    return returnAnswerSet;
}

// this method accepts a profile id and returns all her answer objects in an array
- (NSMutableArray *)returnAnswersArrayByProfileID:(int)profileid {
    
    NSMutableArray *returnAnswerSet = [[NSMutableArray alloc] init];
    
    NSLog(@"_answers %@", _answers[0][[NSString stringWithFormat:@"%d",profileid]]);
    
    
    NSLog(@"profileid %d", profileid);
    
    for(id key in _answers[0][[NSString stringWithFormat:@"%d",profileid]]) {
        
        NSDictionary *questionObject =  [_questionFactoryObject returnQuestionByQuestionID:[key intValue]];
        
        if([questionObject[@"author_id"] intValue] != profileid) {
            [returnAnswerSet addObject:key];
        }
    }
    
    return returnAnswerSet;
}

// this method adds answers to a particular user's set
- (void)pushAnswer:(int)questionid :(int)answersubmitted :(int)userid {
    
    NSMutableDictionary *operationalAnswerSet = [NSMutableDictionary dictionaryWithDictionary:[self returnAnswersByProfileID:userid]];
    
    [operationalAnswerSet setObject:[NSString stringWithFormat:@"%d",answersubmitted]
                             forKey:[NSString stringWithFormat:@"%d",questionid]];
    
    // have to use copies!
    NSMutableDictionary *operationalAnswerLibrary = [NSMutableDictionary dictionaryWithDictionary:_answers[0]];
    
    [operationalAnswerLibrary setObject:operationalAnswerSet
                              forKey:[NSString stringWithFormat:@"%d",userid]];
    
    [self addAnswerAtIndex:operationalAnswerLibrary :0];
    
}

@end
