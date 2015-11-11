//
//  CPRESTClient.m
//
//
//  Created by gclee on 2015. 3. 5..
//  Copyright (c) 2015년 . All rights reserved.
//

#import "CPRESTClient.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AppDelegate.h"

@implementation CPRESTClient

+ (CPRESTClient *)sharedClient
{
    static CPRESTClient *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:[@"http://" stringByAppendingString:BASE_DOMAIN]];
        sharedInstance = [[CPRESTClient alloc] initWithBaseURL:baseURL];
    });
    
    return sharedInstance;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidStart:) name:AFNetworkingOperationDidStartNotification object:nil];
        [self.reachabilityManager startMonitoring];
        
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
		
		AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        [self.requestSerializer setValue:app.userAgent forHTTPHeaderField:@"User-Agent"];
        [self.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
		
		NSLog(@"self.requestSerializer : %@", self.requestSerializer.HTTPRequestHeaders.description);
		
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                          @"application/xml",
                                                          @"text/html",
                                                          @"application/x-javascript",
                                                          @"text/javascript",
                                                          @"text/xml",
                                                          @"text/plain",
                                                          nil];
    }
    
    return self;
}

#pragma mark - Notification

- (void)networkRequestDidStart:(NSNotification *)notification
{
    NSURLRequest *request = [[notification object] request];
    if (request) {
        NSLog(@"networkRequestDidStart request : \n%@\n\n", request.URL.absoluteString);
    }
}

#pragma mark - Private Methods

- (NSDictionary *)encodingResponse:(NSData *)responseData
{
    NSString *encodedString = [[NSString alloc] initWithData:responseData encoding:0x80000422];
    
//    NSLog(@"responseData String: \n\n%@\n", encodedString);
    
    if (!encodedString) {
        encodedString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    }
    
    if (encodedString)  encodedString = [encodedString trim];
    
    NSData *decodedData = [encodedString dataUsingEncoding:NSUTF8StringEncoding];
    if (decodedData == nil) {
        return nil;
    }
    
    NSError *error = nil;
    NSDictionary *jsonObject = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:decodedData options:0 error:&error];
    
    return jsonObject;
}

- (NSDictionary *)encodingResponse:(NSData *)responseData encoding:(NSStringEncoding)encoding
{
    NSString *encodedString = [[NSString alloc] initWithData:responseData encoding:encoding];
    
    //    NSLog(@"responseData String: \n\n%@\n", encodedString);
    
    if (!encodedString) {
        encodedString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    }
    
    if (encodedString)  encodedString = [encodedString trim];
    
    NSData *decodedData = [encodedString dataUsingEncoding:NSUTF8StringEncoding];
    if (decodedData == nil) {
        return nil;
    }
    
    NSDictionary *jsonObject = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:decodedData options:0 error:nil];
    
    return jsonObject;
}

#pragma mark - Preload

- (void)requestPreloadWithUrl:(NSString *)url
                      success:(void (^)(NSDictionary *result))success
                      failure:(void (^)(NSError *error))failure
{
    [self GET:url
   parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSDictionary *result = [self encodingResponse:operation.responseData];
          
          if (success) {
              success(result);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
              failure(error);
          }
      }];
}

- (void)requestServerStatusWithUrl:(NSString *)url
                           success:(void (^)(NSDictionary *result))success
                           failure:(void (^)(NSError *error))failure
{
    [self GET:url
   parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSDictionary *result = [self encodingResponse:operation.responseData];
          
          if (success) {
              success(result);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
              failure(error);
          }
      }];
}

- (void)requestVersionInfoWithUrl:(NSString *)url
                          success:(void (^)(NSDictionary *result))success
                          failure:(void (^)(NSError *error))failure
{
    [self GET:url
   parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSDictionary *result = [self encodingResponse:operation.responseData];
          
          if (success) {
              success(result);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
              failure(error);
          }
      }];
}

#pragma mark - My Page

- (void)requestMyPageWithParam:(NSDictionary *)param
                       success:(void (^)(NSDictionary *result))success
                       failure:(void (^)(NSError *error))failure
{
    [self GET:param[@"apiUrl"]
   parameters:param
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSDictionary *result = [self encodingResponse:operation.responseData];
          
          if (success) {
              success(result);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
              failure(error);
          }
      }];
}

#pragma mark - Search

- (void)requestSearchWithUrl:(NSString *)url
                     success:(void (^)(NSDictionary *result))success
                     failure:(void (^)(NSError *error))failure
{
    [self GET:url
   parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSDictionary *result = [self encodingResponse:operation.responseData encoding:NSUTF8StringEncoding];
          
          if (success) {
              success(result);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
              failure(error);
          }
      }];
}

#pragma mark - mainTab (request cache)

- (void)requestCacheWithParam:(NSDictionary *)param
                      success:(void (^)(NSDictionary *result))success
                      failure:(void (^)(NSError *error))failure
{
    [self GET:param[@"apiUrl"]
   parameters:param
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSDictionary *result = [self encodingResponse:operation.responseData];
          
          if (success) {
              success(result);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
              failure(error);
          }
      }];
}

#pragma mark - mainTab (request ignore cache)

- (void)requestIgnoreCacheWithParam:(NSDictionary *)param
                            success:(void (^)(NSDictionary *result))success
                            failure:(void (^)(NSError *error))failure
{
    [self ignoreRequestGet:param[@"apiUrl"]
                parameters:param
                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                       NSDictionary *result = [self encodingResponse:operation.responseData];
                       
                       if (success) {
                           success(result);
                       }
                   }
                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       if (failure) {
                           failure(error);
                       }
                   }];
}



#pragma mark - CategoryMain

- (void)requestCategoryMainWithUrl:url
                           success:(void (^)(NSDictionary *result))success
                           failure:(void (^)(NSError *error))failure
{
    [self GET:url
   parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSDictionary *result = [self encodingResponse:operation.responseData];
          
          if (success) {
              success(result);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
              failure(error);
          }
      }];
}

#pragma mark - CategoryDetail

- (void)requestCategoryDetailWithUrl:(NSString *)url
                             success:(void (^)(NSDictionary *result))success
                             failure:(void (^)(NSError *error))failure
{
    [self GET:url
   parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSDictionary *result = [self encodingResponse:operation.responseData];
          
          if (success) {
              success(result);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
              failure(error);
          }
      }];
}

#pragma mark - Product List

- (void)requestProductListWithUrl:(NSString *)url
                          success:(void (^)(NSDictionary *result))success
                          failure:(void (^)(NSError *error))failure
{
    [self GET:url
   parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSDictionary *result = [self encodingResponse:operation.responseData];
          
          if (success) {
              success(result);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
              failure(error);
          }
      }];
}

- (void)requestLineBannerWithUrl:(NSString *)url
                         success:(void (^)(NSDictionary *result))success
                         failure:(void (^)(NSError *error))failure
{
    [self GET:url
   parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSDictionary *result = [self encodingResponse:operation.responseData];
          
          if (success) {
              success(result);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
              failure(error);
          }
      }];
}

- (void)requestPowerLinkWithUrl:(NSString *)url
                        success:(void (^)(NSDictionary *result))success
                        failure:(void (^)(NSError *error))failure
{
    [self GET:url
   parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSDictionary *result = [self encodingResponse:operation.responseData];
          
          if (success) {
              success(result);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
              failure(error);
          }
      }];
}

#pragma mark - Seller Info

- (void)requestSellerInfoWithUrl:(NSString *)url
                         success:(void (^)(NSDictionary *result))success
                         failure:(void (^)(NSError *error))failure
{
    [self GET:url
   parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSDictionary *result = [self encodingResponse:operation.responseData];
          
          if (success) {
              success(result);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
              failure(error);
          }
      }];
}

#pragma mark - Offer Banner

- (void)requestGetOfferBannerWithParam:(NSDictionary *)param
                               success:(void (^)(NSDictionary *result))success
                               failure:(void (^)(NSError *error))failure
{
    [self GET:param[@"apiUrl"]
   parameters:param
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSDictionary *result = [self encodingResponse:operation.responseData];
          
          if (success) {
              success(result);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
              failure(error);
          }
      }];
}

- (void)requestUpdateOfferBannerWithParam:(NSDictionary *)param
                                      url:(NSString *)url
                                  success:(void (^)(NSDictionary *result))success
                                  failure:(void (^)(NSError *error))failure
{
    [self GET:url
   parameters:param
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSDictionary *result = [self encodingResponse:operation.responseData];
          
          if (success) {
              success(result);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
              failure(error);
          }
      }];
}

#pragma mark - Product

- (void)requestProductDetailWithUrl:url
                            success:(void (^)(NSDictionary *result))success
                            failure:(void (^)(NSError *error))failure
{
    [self GET:url
   parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSDictionary *result = [self encodingResponse:operation.responseData];
          
          if (success) {
              success(result);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
              failure(error);
          }
      }];
}

- (void)requestProductDetailWithUrl:url
                              param:(NSDictionary *)param
                            success:(void (^)(NSDictionary *result))success
                            failure:(void (^)(NSError *error))failure
{
    [self GET:url
   parameters:param
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSDictionary *result = [self encodingResponse:operation.responseData];
          
          if (success) {
              success(result);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
              failure(error);
          }
      }];
}

- (void)requestProductLiveDataWithUrl:url
                              param:(NSDictionary *)param
                            success:(void (^)(NSDictionary *result))success
                            failure:(void (^)(NSError *error))failure
{
    [self POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *result = [self encodingResponse:operation.responseData];
        
        if (success) {
            success(result);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
