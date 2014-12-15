//
//  PointSet_Factory.h
//  around
//
//  Created by Benjamin McFerren on 6/4/14.
//  Copyright (c) 2014 DePaul University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PointSet_Factory : NSObject

// this is a singlton object that uses thread checking to ensure that it is only invoked once and subsequant requests return the previously instantiated object
+ (instancetype)sharedPointSetFactory;

// array property that holds a fixed amount of profiles
- (NSArray *)pointsets;

// these are public methods accessible from the static object
- (void)pushPoint:(NSDictionary*)pointsubmitted :(int)userid :(int)friendid;
- (NSMutableDictionary *)returnPointSetByProfileID:(int)profileid;
- (NSMutableArray *)returnPointSetArrayByProfileID:(int)profileid;

@end
