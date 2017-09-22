//
//  APIDataFetcher.m
//
//  Created by Nirav Bhatt on 9/5/15.
//  Copyright (c) 2015 IphoneGameZone. All rights reserved.
/* Generic JSON fetch routines through NSURLConnection
 Part of: https://github.com/vividcode/iOSAPIDataApp/tree/master/iOSAPIDataApp
 */

#import "APIDataFetcher.h"

static NSOperationQueue * _connectionQueue = nil;
static NSURLSession * _session = nil;
static APIDataFetcher *fetch = nil;

@implementation APIDataFetcher
@synthesize licenceTypeDict;
//+(APIDataFetcher *)fetcher
//{
//    
//    @synchronized(self)
//    {
//        if(fetch==nil)
//        {
//            fetch=[APIDataFetcher new];
//            fetch.licenceTypeDict=[NSMutableDictionary dictionary];
//        }
//    }
//    return fetch;
//}
+ (NSOperationQueue *) connectionQueue
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_connectionQueue)
        {
            _connectionQueue = [[NSOperationQueue alloc] init];
            
        }
    });
    return _connectionQueue;
}

+ (void) createURLSession
{
    static dispatch_once_t onceToken;
    
    if (!_session)
    {
        dispatch_once(&onceToken, ^{
            _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        });
    }
}
+(BOOL)reachability
{
    Reachability *rech=[Reachability reachabilityForInternetConnection];
    [rech startNotifier];
    
    return [rech connectionRequired];
}
+ (void) loadDataFromAPIUsingSession : (NSString *) url : (SuccessBlock) successBlock :(FailureBlock) failureBlock
{
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [self createURLSession];
    if (![self reachability]) {

    NSURLSessionDataTask * task = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (response != nil)
        {
            if ([[self acceptableStatusCodes] containsIndex:[(NSHTTPURLResponse *)response statusCode]])
            {
                if ([data length] > 0)
                {
                    NSError *jsonError  = nil;
                    id jsonObject  = nil;
                    
                    jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonObject != nil)
                    {
                        [self presentData:jsonObject :successBlock];
                    }
                    else
                    {
                        [self presentError:jsonError reachebility:NO :failureBlock];
                    }
                }
                else
                {
                    [self presentError:nil reachebility:NO :failureBlock];
                }
            }
            else
            {
                [self presentError:nil reachebility:NO :failureBlock];
            }
        }
        else
        {
            [self presentError:error reachebility:NO :failureBlock];
        }
    }];
        [task resume];

    } else {
        
        [self presentError:nil reachebility:YES :failureBlock];

    }
    
}

+ (void) loadDataFromAPI : (NSString *) url : (SuccessBlock) successBlock :(FailureBlock) failureBlock
{
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[self connectionQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (response != nil)
         {
             if ([[self acceptableStatusCodes] containsIndex:[(NSHTTPURLResponse *)response statusCode] ])
             {
                 if ([data length] > 0)
                 {
                     NSError *jsonError  = nil;
                     id jsonObject  = nil;
                     
                     jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                     
                     if (jsonObject != nil)
                     {
                         [self presentData:jsonObject :successBlock];
                     }
                     else
                     {
                         [self presentError:jsonError reachebility:NO :failureBlock];
                     }
                 }
                 else
                 {
                     [self presentError:nil reachebility:NO :failureBlock];
                 }
             }
             else
             {
                 [self presentError:nil reachebility:NO :failureBlock];
             }
         }
         else
         {
             [self presentError:connectionError reachebility:NO :failureBlock];
         }
     }];
}

+ (NSIndexSet *) acceptableStatusCodes
{
    return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 99)];
}

+ (void) presentData:(id)jsonObject :(SuccessBlock) block
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:
     ^{
         block(jsonObject);
     }];
}

+ (void) presentError:(NSError *)error  reachebility:(BOOL)rech :(FailureBlock) block
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:
     ^{
         block(error,error.localizedDescription,rech);
     }];
}
@end
