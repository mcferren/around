//
//  Profile_DAO.m
//  around
//
//  Created by Ben Mcferren on 12/17/14.
//  Copyright (c) 2014 Sea * Side Syndication. All rights reserved.
//

#import "Profile_DAO.h"

// Set this to your Trakt API Key
NSString * const kTraktAPIKey = @"027d9f99d2a9e3f8c51bd2ee9ab1970b";
NSString * const kTraktBaseURLString = @"http://api.trakt.tv";

@implementation Profile_DAO

+ (Profile_DAO *)sharedClient {
    static Profile_DAO *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kTraktBaseURLString]];
    });
    return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    return self;
}

- (void)getShowsForDate:(NSDate *)date
               username:(NSString *)username
           numberOfDays:(int)numberOfDays
                success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd";
    NSString* dateString = [formatter stringFromDate:date];
    
    NSString* path = [NSString stringWithFormat:@"user/calendar/shows.json/%@/%@/%@/%d",
                      kTraktAPIKey, username, dateString, numberOfDays];
    
    [self GET:path
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
      }
    }];
}

@end
