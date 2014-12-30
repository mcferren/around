//
//  DAO.m
//  around
//
//  Created by Ben Mcferren on 12/22/14.
//  Copyright (c) 2014 Sea * Side Syndication. All rights reserved.
//

#import "DAO.h"

// Set this to your Trakt API Key
//NSString * const parrotAPIKey = @"027d9f99d2a9e3f8c51bd2ee9ab1970b";
NSString * const parrotBaseURLString = @"https://thawing-mountain-1681.herokuapp.com/";

@implementation DAO

+ (DAO *)sharedClient {
    static DAO *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:parrotBaseURLString]];
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

- (void)getUserData:(void (^)(id responseObject, NSError *error))completionHandler {
    
    [FBRequestConnection startWithGraphPath:@"/me?fields=name,likes.fields(name,picture.width(300).height(300)).limit(500),friends.fields(name,picture.width(300).height(300)).limit(500)"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id responseObject,
                                              NSError *error
                                              ) {
                              
                              
                              if (!error) {
                                  // Success! Include your code to handle the results here
                                  //                                  NSMutableArray *zippy = [responseObject objectForKey:@"data"];
                                  //                                  NSLog(@"user FUNNY info: %@", zippy[@"id"]);
                                  //                                  NSLog(@"user_id PUTS %@", responseObject[@"id"]);
                                  
                                  //                                  NSError *error;
                                  //                                  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:zippy
                                  //                                                                                     options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                  //                                                                                       error:&error];
                                  //                                  NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                  
                                  // prepare for post
//                                  responseObject = @{ @"userid" : responseObject[@"id"] };
//                                  NSLog(@"user_id %@", responseObject);
                                  
                                  //                                   }];
                                  // prepare for post
//                                  NSObject * payload = @{ @"user_object" : responseObject };
                                  NSObject * payload = @{ @"user_object" : responseObject };
                                  
                                  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                                  manager.requestSerializer = [AFJSONRequestSerializer serializer];
                                  
                                  [manager POST:@"http://localhost:3000/user"
                                     parameters:payload
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            if (completionHandler) {
                                                completionHandler(responseObject, nil);
                                                
//                                                NSLog(@"Karl %@", responseObject);
                                            }
                                        }
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            if (completionHandler) {
                                                completionHandler(nil, error);
                                            }
                                        }];
                              } else {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"error %@", error.description);
                              }
                              
                          }];
}


//- (void)postFacebookData:(void (^)(id responseObject, NSError *error))completionHandler
//              withObject:(NSObject *)facebookObject
//{
//    // prepare for post
//    NSObject * payload = @{ @"word" : facebookObject };
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    
//    [manager POST:@"https://thawing-mountain-1681.herokuapp.com/funky"
//       parameters:payload
//          success:^(AFHTTPRequestOperation *operation, id responseObject) {
//              if (completionHandler) {
//                  completionHandler(responseObject, nil);
//              }
//          }
//          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//              if (completionHandler) {
//                  completionHandler(nil, error);
//              }
//          }];
//}


- (void)postQuestion:(void (^)(id responseObject, NSError *error))completionHandler
           withObject:(NSObject *)questionObject
{
    // prepare for post
    NSObject * payload = @{ @"question_object" : questionObject };

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //                                  manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:@"http://localhost:3000/question"
       parameters:payload
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              if (completionHandler) {
                  completionHandler(responseObject, nil);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (completionHandler) {
                  completionHandler(nil, error);
              }
          }];
}

@end
