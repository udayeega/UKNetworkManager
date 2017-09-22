//
//  APIDataFetcher.h
//  APITest
//
//  Created by Admin on 9/5/15.
//  Copyright (c) 2015 IphoneGameZone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"


typedef void (^SuccessBlock)(id result);
typedef void (^FailureBlock)(NSError * error,NSString *errorDescription,BOOL notReachable);

@interface APIDataFetcher : NSObject
@property(strong,nonatomic) NSMutableDictionary *licenceTypeDict;

+ (NSOperationQueue *) connectionQueue;
//+(APIDataFetcher *)fetcher;
+ (void) loadDataFromAPI : (NSString *) url : (SuccessBlock) successBlock :(FailureBlock) failureBlock;

+ (void) loadDataFromAPIUsingSession : (NSString *) url : (SuccessBlock) successBlock :(FailureBlock) failureBlock;

@end
