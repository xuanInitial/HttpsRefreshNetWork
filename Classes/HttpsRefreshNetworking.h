//
//  HttpsRefreshNetworking.h
//  Glaucus
//
//  Created by bihu_Mac on 2017/7/14.
//  Copyright © 2017年 minmei. All rights reserved.
//




#import <Foundation/Foundation.h>

@class HttpsRefreshNetworking;

@interface HttpsRefreshNetworking : NSObject


+ (instancetype)Networking;//实例化

//POST不缓存
- (HttpsRefreshNetworking *)POST:(NSString *)URLString
                   parameters:(id)parameters//参数
                      success:(void (^)( NSDictionary *allHeaders, id responseObject,id statusCode))success//请求成功
                      failure:(void (^)( NSDictionary *allHeaders,NSError *error,id statusCode))failure;//请求失败

//GET不缓存
- (HttpsRefreshNetworking *)GET:(NSString *)URLString
                  parameters:(id)parameters//参数
                     success:(void (^)(NSDictionary *allHeaders, id responseObject,id statusCode))success//请求成功
                     failure:(void (^)(NSDictionary *allHeaders,NSError *error,id statusCode))failure;//请求失败

//POST带缓存
- (HttpsRefreshNetworking *)POST:(NSString *)URLString
                   parameters:(id)parameters//参数
                    CacheData:(void (^)(id responseObject))CacheData//沙盒数据
                      success:(void (^)(id responseObject))success//请求成功
                      failure:(void (^)(NSError *error))failure;//请求失败

//GET带缓存
- (HttpsRefreshNetworking *)GET:(NSString *)URLString
                  parameters:(id)parameters//参数
                   CacheData:(void (^)(id responseObject))CacheData//沙盒数据
                     success:(void (^)(id responseObject))success//请求成功
                     failure:(void (^)(NSError *error))failure;//请求失败

//清除指定缓存
- (void)removeCacheUrlData:(NSString *)string parameters:(id)parameters;//参数;

//清除所有目录下请求缓存
- (void)removeAllUrlData;


@end
