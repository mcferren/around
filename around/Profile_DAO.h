//
//  Profile_DAO.h
//  around
//
//  Created by Ben Mcferren on 12/17/14.
//  Copyright (c) 2014 Sea * Side Syndication. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

extern NSString * const kTraktAPIKey;
extern NSString * const kTraktBaseURLString;

@interface Profile_DAO : AFHTTPSessionManager

+ (Profile_DAO *)sharedClient;

- (void)getShowsForDate:(NSDate *)date
               username:(NSString *)username
           numberOfDays:(int)numberOfDays
                success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

@end