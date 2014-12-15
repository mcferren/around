//
//  PointSet_Factory.m
//  around
//
//  Created by Benjamin McFerren on 6/4/14.
//  Copyright (c) 2014 DePaul University. All rights reserved.
//

#import "PointSet_Factory.h"
#include <stdlib.h>

@interface PointSet_Factory ()

@property(strong, nonatomic) NSMutableArray *pointsets;
@property (copy, nonatomic) NSDictionary *names;

@end

@implementation PointSet_Factory

// this method declares the core components needed for the singlton to deliver the correct type of information
- (instancetype)init {
    self = [super init];
    if (self) {
        NSUserDefaults *defaults =
        [NSUserDefaults standardUserDefaults];
        NSArray *storedPointSets = [defaults objectForKey:@"pointsetobjects"];
        if (storedPointSets) { // mutable means can change
            self.pointsets = [storedPointSets mutableCopy];
        } else {
            self.pointsets = [NSMutableArray array];
        }
        
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"pointsets" ofType:@"plist"];
        self.names = [NSDictionary dictionaryWithContentsOfFile:path];
        
        [self populatePointSets];
        
    }
    return self;
}

// this conditionally checks whether the object has once been created and rreturns the original if it already has
+ (instancetype)sharedPointSetFactory {
    
    static PointSet_Factory *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ // also used in threading
        shared = [[self alloc] init];
    });
    return shared;
}


// this utility method prepopulates the pointset elements with certain key value pairs
- (void)populatePointSets {
    [_pointsets removeAllObjects];
    
    for(id key in self.names) {
        [self addPointSet:[self.names objectForKey:key]];
    }
    
//    NSLog(@"&&&& POINT SETS &&&& %@", _pointsets[0]);
}



- (NSMutableDictionary *)returnPointSetByProfileID:(int)profileid {
    
//    NSDictionary *returnPointSet = _pointsets[0][[NSString stringWithFormat:@"%d",profileid]];
    NSMutableDictionary *returnPointSet = [NSMutableDictionary dictionaryWithDictionary:_pointsets[0][[NSString stringWithFormat:@"%d",profileid]]];
    
//    NSLog(@"returnPointSet %@", returnPointSet);
    
    return returnPointSet;
}

// this method returns an array of points so that the points view controller can use is as a datasource
- (NSMutableArray *)returnPointSetArrayByProfileID:(int)profileid {
    
    NSMutableArray *returnPointSet = [[NSMutableArray alloc] init];
    
    for(id key in _pointsets[0][[NSString stringWithFormat:@"%d",profileid]]) {
        if([key intValue] != profileid) {
            [returnPointSet addObject:key];
        }
    }
    
    NSLog(@"returnPointSet %@", returnPointSet);
    
    return returnPointSet;
}

// this is a public method that receives two profile id and the method is expected to increment their point totals
- (void)pushPoint:(NSDictionary*)pointsubmitted :(int)userid :(int)friendid {
    
    
    NSMutableDictionary *operationalPointSet = [NSMutableDictionary dictionaryWithDictionary:[self returnPointSetByProfileID:userid]];
    
    // if the two have previously shared points or not
    if(operationalPointSet[[NSString stringWithFormat:@"%d",friendid]] != nil) {
        
        [operationalPointSet[[NSString stringWithFormat:@"%d",friendid]] addObject:pointsubmitted];
        
    } else {
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        
        [tempArray addObject:pointsubmitted];
        
        [operationalPointSet setObject:tempArray
                                forKey:[NSString stringWithFormat:@"%d",friendid]];
    }
    
    NSMutableDictionary *operationalPointSetLibrary = [NSMutableDictionary dictionaryWithDictionary:_pointsets[0]];
    
    [operationalPointSetLibrary setObject:operationalPointSet
                                   forKey:[NSString stringWithFormat:@"%d",userid]];
    
    [self addPointSetAtIndex:operationalPointSetLibrary :0];
    
}


// this utility method allow to add a pointset element at a specific index
- (void)addPointSetAtIndex:(id)item :(int)itemnumber {
    
    [_pointsets removeObjectAtIndex:itemnumber];
    [_pointsets insertObject:item atIndex:itemnumber];
    [self savePointSets];
    
}

// this is a general go to purpose method used to insert the object it recevies into the class property array. It forces intent by invokeng the save method
- (void)addPointSet:(id)item {
    [_pointsets insertObject:item atIndex:0];
    [self savePointSets];
}


// this is a general go to purpose method used to remove the object it recevies into the class property array. It forces intent by invokeng the save method
- (void)removePointSet:(int)itemnumber {
    [_pointsets removeObjectAtIndex:itemnumber];
    [self savePointSets];
}

// this method ensures the NSUser Defaults are kept up to date when changing the elements in the class array property
- (void)savePointSets {
    NSUserDefaults *defaults =
    [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.pointsets forKey:@"pointsetobjects"];
    [defaults synchronize];
}

// this is a simple swapping method
- (void)movePointSetAtIndex:(NSInteger)from toIndex:(NSInteger)to {
    id item = _pointsets[from];
    [_pointsets removeObjectAtIndex:from];
    [_pointsets insertObject:item atIndex:to];
    [self savePointSets];
}

// this factory method takes an int as an argument and returns that many pointset doctionary objects inside of an array
- (NSMutableArray *)returnPointSets:(int)quantity {
    
    NSMutableArray *returnArray = [NSMutableArray array];
    
    int r;
    
    for(int i = 0; i < quantity; ++i) {
        
        r = arc4random() % (int)[_pointsets count];
        
        // we are returning a copy
        [returnArray addObject:@{@"profile_ID":_pointsets[r][@"profile_ID"],
                                 @"name":_pointsets[r][@"name"],
                                 @"avatar":_pointsets[r][@"avatar"]
                                 }];
        
        //        NSLog(@"returnHURRAY %@", returnArray);
    }
    
    return returnArray;
    
}

@end
