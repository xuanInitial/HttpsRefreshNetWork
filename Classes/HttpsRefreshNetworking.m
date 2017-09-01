//
//  HttpsRefreshNetworking.m
//  Glaucus
//
//  Created by bihu_Mac on 2017/7/14.
//  Copyright © 2017年 minmei. All rights reserved.
//

#import "HttpsRefreshNetworking.h"
#import "AFNetworking.h"
#import <CommonCrypto/CommonDigest.h>

@implementation HttpsRefreshNetworking


+ (instancetype)Networking{
    return [[HttpsRefreshNetworking alloc] init];
    
}


#pragma mark--  POST  不缓存
- (HttpsRefreshNetworking *)POST:(NSString *)URLString
                      parameters:(id)parameters//参数
                         success:(void (^)(NSDictionary *allHeaders, id responseObject,id statusCode))success//请求成功
                         failure:(void (^)(NSDictionary *allHeaders,NSError *error,id statusCode))failure;//请求失败
{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    securityPolicy.allowInvalidCertificates = YES;
    [AFHTTPSessionManager manager].securityPolicy = securityPolicy;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css",@"text/plain", nil]];
    
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic addEntriesFromDictionary:parameters];
    
    
     NSDictionary *temparameters=[self refineUsrWithDic:dic];
    
    [manager POST:URLString parameters:temparameters constructingBodyWithBlock:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {//返回加载成功的数据
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            NSDictionary *allHeaders = response.allHeaderFields;
            success(allHeaders,responseObject,[NSString stringWithFormat:@"%ld",(long)[response statusCode]]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {//返回错误信息
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            NSDictionary *allHeaders = response.allHeaderFields;
            failure(allHeaders, error,[NSString stringWithFormat:@"%ld",(long)[response statusCode]]);
        }
    }];
    
    return self;
}




#pragma mark  Get  不缓存
- (HttpsRefreshNetworking *)GET:(NSString *)URLString
                     parameters:(id)parameters//参数
                        success:(void (^)(NSDictionary *allHeaders, id responseObject,id statusCode))success//请求成功
                        failure:(void (^)(NSDictionary *allHeaders,NSError *error,id statusCode))failure;//请求失败
{
    AFHTTPSessionManager *httpManager = [AFHTTPSessionManager manager];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    securityPolicy.allowInvalidCertificates = YES;
    [AFHTTPSessionManager manager].securityPolicy = securityPolicy;
    httpManager.responseSerializer = [AFJSONResponseSerializer serializer];
    httpManager.requestSerializer=[AFJSONRequestSerializer serializer];
    [httpManager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css",@"text/plain", nil]];
    
    [httpManager GET:URLString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {//返回加载成功的数据
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            NSDictionary *allHeaders = response.allHeaderFields;
            success(allHeaders, responseObject,[NSString stringWithFormat:@"%ld",(long)[response statusCode]]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {//返回错误信息
            
             NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
             NSDictionary *allHeaders = response.allHeaderFields;
            failure(allHeaders,error,[NSString stringWithFormat:@"%ld",(long)[response statusCode]]);
        }
    }];
    
    return self;
}

















//POST
- (HttpsRefreshNetworking *)POST:(NSString *)URLString
                   parameters:(id)parameters
                    CacheData:(void (^)(id responseObject))CacheData//沙盒数据
                      success:(void (^)(id responseObject))success//请求成功
                      failure:(void (^)(NSError *error))failure;//请求失败
{
    NSString *cacheStr;
    if (parameters) {
        cacheStr = [NSString stringWithFormat:@"%@/%@",URLString,[self DictionaryToString:parameters]];
    } else {
        cacheStr = [NSString stringWithFormat:@"%@",URLString];
    }
    
    if (CacheData) {//先返回缓存数据
        CacheData([self GetCacheData:cacheStr]);
    }
    
    [self POST:URLString parameters:parameters success:^(NSDictionary *allHeaders,id responseObject,id statusCode) {
        if (success) {//返回加载成功的数据
            [self SetCacheData:responseObject urlStr:cacheStr];
            success(responseObject);
        }
    } failure:^(NSDictionary *allHeaders, NSError *error ,id statusCode) {
        if (failure) {//返回错误信息
            
            failure(error);
        }
    }];
    
    return self;
}

- (HttpsRefreshNetworking *)GET:(NSString *)URLString
                  parameters:(id)parameters//参数
                   CacheData:(void (^)(id responseObject))CacheData//沙盒数据
                     success:(void (^)(id responseObject))success//请求成功
                     failure:(void (^)(NSError *error))failure;//请求失败
{
    NSString *cacheStr;
    if (parameters) {
        cacheStr = [NSString stringWithFormat:@"%@/%@",URLString,[self DictionaryToString:parameters]];
    } else {
        cacheStr = [NSString stringWithFormat:@"%@",URLString];
    }
    
    if (CacheData) {//先返回缓存数据
        CacheData([self GetCacheData:cacheStr]);
    }
    
    [self GET:URLString parameters:parameters success:^(NSDictionary *allHeaders, id responseObject,id statusCode) {
        if (success) {//返回加载成功的数据
            [self SetCacheData:responseObject urlStr:cacheStr];
            success(responseObject);
        }
    } failure:^(NSDictionary *allHeaders,NSError *error ,id statusCode) {
        if (failure) {//返回错误信息
            failure(error);
        }
    }];
    
    return self;
}





#pragma mark - 沙盒
//获取到对应的沙盒存储数据
- (id)GetCacheData:(NSString *)CacheUrl{
    //  NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *sandPath = NSHomeDirectory();
    //  NSString *filePath = [sandPath stringByAppendingPathComponent:@"XYCaches/"];
    //  [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    //文件路径
    CacheUrl = [NSString stringWithFormat:@"Documents/XYCaches/%@.txt",[self cachedFileNameForKey:CacheUrl]];
    NSString *path = [sandPath stringByAppendingPathComponent:CacheUrl];
    //读取文件内容
    NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *dataDic = [self StringToDictionary:string];
    
    return dataDic;
}

//预先缓存数据
- (void)SetCacheData:(id)CacheData urlStr:(NSString *)string{
    [self removeCacheUrlData:string];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *sandPath = NSHomeDirectory();
    NSString *filePath = [sandPath stringByAppendingPathComponent:@"Documents/XYCaches/"];
    [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *dataStr = [self DictionaryToString:CacheData];
    //文件路径
    string = [NSString stringWithFormat:@"Documents/XYCaches/%@.txt",[self cachedFileNameForKey:string]];
    NSString *path = [sandPath stringByAppendingPathComponent:string];
    //将字符串写入文件中
    [dataStr writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

//清除指定缓存
- (void)removeCacheUrlData:(NSString *)string parameters:(id)parameters {
    NSString *cacheStr = nil;
    if (parameters) {
        cacheStr = [NSString stringWithFormat:@"%@/%@",string,[self DictionaryToString:parameters]];
    } else {
        cacheStr = [NSString stringWithFormat:@"%@",string];
    }
    [self removeCacheUrlData:cacheStr];
}

- (void)removeCacheUrlData:(NSString *)string{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *sandPath = NSHomeDirectory();
    //文件路径
    string = [NSString stringWithFormat:@"Documents/XYCaches/%@.txt",[self cachedFileNameForKey:string]];
    NSString *filePath = [sandPath stringByAppendingPathComponent:string];
    
    [fileManager removeItemAtPath:filePath error:nil];
}

//清除所有缓存
- (void)removeAllUrlData{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *sandPath = NSHomeDirectory();
    NSString *filePath = [sandPath stringByAppendingPathComponent:@"Documents/XYCaches/"];
    [fileManager removeItemAtPath:filePath error:nil];
}

#pragma mark - 数据转换操作
- (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    return filename;
}

//字符串转字典
- (NSDictionary *)StringToDictionary:(NSString *)string{
    
    if (string.length == 0) {
        return [NSDictionary dictionary];
    }
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    
    if (error) {
        return [NSDictionary dictionary];
    }else{
        return dic;
    }
}

//字典转字符串
- (NSString *)DictionaryToString:(NSDictionary *)dictionary{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


-(NSDictionary *)refineUsrWithDic:(NSDictionary *)parmDic{
    
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic addEntriesFromDictionary:parmDic];
    
   // [dic setValue:[self md5:[BHGlobalHelper getDeviceID]] forKey:@"CustKey"];
    
    
    NSMutableDictionary *parameters=[NSMutableDictionary dictionary];
    [parameters addEntriesFromDictionary:dic];
    NSString *_sckode=[[self dictionaryUsrToMD5 :dic] lowercaseString];
    [parameters setValue:_sckode forKey:@"secCode"];
    
    return parameters;
}
-(NSString *)dictionaryUsrToMD5:(NSDictionary *)dict{
    
    [dict setValue:@"Z3srCAJsXLwmNikn30Sj" forKey:@"secretKey"];
    NSDictionary *temDic=[NSDictionary dictionaryWithDictionary:dict];
    NSMutableString *queryStr=[NSMutableString string];
    
    NSArray *sortedKeys = [[temDic allKeys] sortedArrayUsingSelector: @selector(compare:)];
    
    for (NSString *aKey in sortedKeys) {
        [queryStr appendFormat:@"%@=%@",aKey,[dict objectForKey:aKey] ];
        [queryStr appendString:@"&"];
    }
    NSRange range = NSMakeRange(0,([queryStr length]-1));
    NSString *_tem= [queryStr substringWithRange:range];
        NSLog(@"去掉&的串:%@",_tem);
    return [self md5:_tem];
}

- (NSString *)md5:(NSString *)str{
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    
    return result;
}



@end
