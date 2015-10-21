//
//  CPRESTClient.h
//  11st
//
//  Created by spearhead on 2015. 3. 5..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

@interface CPRESTClient : AFHTTPRequestOperationManager

+ (CPRESTClient *)sharedClient;

#pragma mark - Preload

- (void)requestPreloadWithUrl:(NSString *)url
                      success:(void (^)(NSDictionary *result))success
                      failure:(void (^)(NSError *error))failure;

- (void)requestServerStatusWithUrl:(NSString *)url
                           success:(void (^)(NSDictionary *result))success
                           failure:(void (^)(NSError *error))failure;

- (void)requestVersionInfoWithUrl:(NSString *)url
                          success:(void (^)(NSDictionary *result))success
                          failure:(void (^)(NSError *error))failure;

#pragma mark - My Page

- (void)requestMyPageWithParam:(NSDictionary *)param
                       success:(void (^)(NSDictionary *result))success
                       failure:(void (^)(NSError *error))failure;

#pragma mark - Search

- (void)requestSearchWithUrl:(NSString *)url
                     success:(void (^)(NSDictionary *result))success
                     failure:(void (^)(NSError *error))failure;

#pragma mark - mainTab (request cache)

- (void)requestCacheWithParam:(NSDictionary *)param
                      success:(void (^)(NSDictionary *result))success
                      failure:(void (^)(NSError *error))failure;

#pragma mark - mainTab (request ignore cache)

- (void)requestIgnoreCacheWithParam:(NSDictionary *)param
                            success:(void (^)(NSDictionary *result))success
                            failure:(void (^)(NSError *error))failure;

#pragma mark - CategoryMain

- (void)requestCategoryMainWithUrl:(NSString *)url
                           success:(void (^)(NSDictionary *result))success
                           failure:(void (^)(NSError *error))failure;

#pragma mark - CategoryDetail

- (void)requestCategoryDetailWithUrl:(NSString *)url
                             success:(void (^)(NSDictionary *result))success
                             failure:(void (^)(NSError *error))failure;

#pragma mark - Product List

- (void)requestProductListWithUrl:(NSString *)url
                          success:(void (^)(NSDictionary *result))success
                          failure:(void (^)(NSError *error))failure;

- (void)requestLineBannerWithUrl:(NSString *)url
                         success:(void (^)(NSDictionary *result))success
                         failure:(void (^)(NSError *error))failure;

- (void)requestPowerLinkWithUrl:(NSString *)url
                        success:(void (^)(NSDictionary *result))success
                        failure:(void (^)(NSError *error))failure;

#pragma mark - Seller Info

- (void)requestSellerInfoWithUrl:(NSString *)url
                        success:(void (^)(NSDictionary *result))success
                        failure:(void (^)(NSError *error))failure;

#pragma mark - Offer Banner

- (void)requestGetOfferBannerWithParam:(NSDictionary *)param
                               success:(void (^)(NSDictionary *result))success
                               failure:(void (^)(NSError *error))failure;

- (void)requestUpdateOfferBannerWithParam:(NSDictionary *)param
                                      url:(NSString *)url
                                  success:(void (^)(NSDictionary *result))success
                                  failure:(void (^)(NSError *error))failure;

#pragma mark - Product

- (void)requestProductDetailWithUrl:url
                            success:(void (^)(NSDictionary *result))success
                            failure:(void (^)(NSError *error))failure;

- (void)requestProductDetailWithUrl:url
                              param:(NSDictionary *)param
                            success:(void (^)(NSDictionary *result))success
                            failure:(void (^)(NSError *error))failure;

- (void)requestProductLiveDataWithUrl:url
                                param:(NSDictionary *)param
                              success:(void (^)(NSDictionary *result))success
                              failure:(void (^)(NSError *error))failure;

@end
