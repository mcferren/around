//
//  DAO.h
//  around
//
//  Created by Ben Mcferren on 12/22/14.
//  Copyright (c) 2014 Sea * Side Syndication. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <FacebookSDK/FacebookSDK.h>

extern NSString * const parrotAPIKey;
extern NSString * const parrotBaseURLString;

@interface DAO : AFHTTPSessionManager

+ (DAO *)sharedClient;

- (void)postQuestion:(void (^)(id responseObject, NSError *error))completionHandler
          withObject:(NSObject *)questionObject;

- (void)getUserData:(void (^)(id responseObject, NSError *error))completionHandler;


@end