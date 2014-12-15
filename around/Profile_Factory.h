//
//  Profile_Factory.h
//  around
//
//  Created by Benjamin McFerren on 6/2/14.
//  Copyright (c) 2014 DePaul University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Profile_Factory : NSObject

// this is a singlton object that uses thread checking to ensure that it is only invoked once and subsequant requests return the previously instantiated object
+ (instancetype)sharedProfileFactory;

// array property that holds a fixed amount of profiles
- (NSArray *)profiles;

// these are public methods accessible from the static object
- (NSMutableArray *)returnProfiles:(int)quantity;
- (NSDictionary *)returnProfilebyId:(int)profile_id;

@end
