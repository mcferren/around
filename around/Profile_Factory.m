//
//  Profile_Factory.m
//  around
//
//  Created by Benjamin McFerren on 6/2/14.
//  Copyright (c) 2014 DePaul University. All rights reserved.
//

#import "Profile_Factory.h"
#include <stdlib.h>

@interface Profile_Factory ()

    @property(strong, nonatomic) NSMutableArray *profiles;
    @property (copy, nonatomic) NSDictionary *names;

@end

@implementation Profile_Factory

// this method declares the core components needed for the singlton to deliver the correct type of information
- (instancetype)init {
    self = [super init];
    if (self) {
        NSUserDefaults *defaults =
        [NSUserDefaults standardUserDefaults];
        NSArray *storedProfiles = [defaults objectForKey:@"profileobjects"];
        if (storedProfiles) { // mutable means can change
            self.profiles = [storedProfiles mutableCopy];
        } else {
            self.profiles = [NSMutableArray array];
        }
        
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"profiles" ofType:@"plist"];
        self.names = [NSDictionary dictionaryWithContentsOfFile:path];
        
//        NSLog(@"NAMES %@", self.names);
//        NSLog(@"keys %@", self.keys);
        
        [self populateProfiles];
        
//        NSLog(@"profilesObject %@", self.profiles);
        
    }
    return self;
}

// this conditionally checks whether the object has once been created and rreturns the original if it already has
+ (instancetype)sharedProfileFactory {
    
    static Profile_Factory *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ // also used in threading
        shared = [[self alloc] init];
    });
    return shared;
}


// this utility method prepopulates the profile elements with certain key value pairs
- (void)populateProfiles {
    [_profiles removeAllObjects];
    
    for(id key in self.names) {
        [self addProfile:[self.names objectForKey:key]];
    }
}

// this utility method allow to add a profile element at a specific index
- (void)addProfileAtIndex:(id)item :(int)itemnumber {
    
    [_profiles removeObjectAtIndex:itemnumber];
    [_profiles insertObject:item atIndex:itemnumber];
    [self saveProfiles];
    
}

// this is a general go to purpose method used to insert the object it recevies into the class property array. It forces intent by invokeng the save method
- (void)addProfile:(id)item {
    [_profiles insertObject:item atIndex:0];
    [self saveProfiles];
}


// this is a general go to purpose method used to remove the object it recevies into the class property array. It forces intent by invokeng the save method
- (void)removeProfile:(int)itemnumber {
    [_profiles removeObjectAtIndex:itemnumber];
    [self saveProfiles];
}

// this method ensures the NSUser Defaults are kept up to date when changing the elements in the class array property
- (void)saveProfiles {
    NSUserDefaults *defaults =
    [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.profiles forKey:@"profileobjects"];
    [defaults synchronize];
}

// this is a simple swapping method
- (void)moveProfileAtIndex:(NSInteger)from toIndex:(NSInteger)to {
    id item = _profiles[from];
    [_profiles removeObjectAtIndex:from];
    [_profiles insertObject:item atIndex:to];
    [self saveProfiles];
}

// this factory method takes an int as an argument and returns that many profile doctionary objects inside of an array
- (NSMutableArray *)returnProfiles:(int)quantity {
    
    NSMutableArray *returnArray = [NSMutableArray array];
    
    int r;
    
    for(int i = 0; i < quantity; ++i) {
        
        r = arc4random() % (int)[_profiles count];
        
        // we are returning a copy
        [returnArray addObject:@{@"profile_ID":_profiles[r][@"profile_ID"],
                                 @"name":_profiles[r][@"name"],
                                 @"avatar":_profiles[r][@"avatar"]
        }];
        
//        NSLog(@"returnHURRAY %@", returnArray);
    }
    
    return returnArray;
    
}


// this method takes a profile id id as an argument as searshes through the profiles in order to return an immutable copy of the profile object
- (NSDictionary *)returnProfilebyId:(int)profile_id {
    
    for (id object in _profiles) {
        
        if([object[@"profile_ID"] intValue] == profile_id) {
            
            return object;
        }
    }
    
    return nil;
}

@end
