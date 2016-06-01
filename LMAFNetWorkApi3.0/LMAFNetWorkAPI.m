//
//  LMAFNetWorkAPI.m
//  LMAFNetWorkApi3.0
//
//  Created by Lim on 16/5/25.
//  Copyright © 2016年 Lim. All rights reserved.
//
# define LMLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#import "LMAFNetWorkAPI.h"
#import "AFNetworkActivityIndicatorManager.h"
static NSMutableArray *tasks;
NSString * const SPHttpCache = @"SPHttpCache";
@implementation LMAFNetWorkAPI
+(instancetype)shareInstance
{
    static LMAFNetWorkAPI *handler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = [[LMAFNetWorkAPI alloc] init];
    });
    return handler;

}
/**
 *  get请求方法,block回调
 *
 *  @param url     请求连接，根路径
 *  @param params  参数
 *  @param success 请求成功返回数据
 *  @param fail    请求失败
 *  @param showHUD 是否显示HUD
 */
+(LMURLSessionTask *)AFNet_GETRequest:(NSDictionary *)params
                            appendUrl:(NSString *)appendUrl
                              success:(SuccessBlock)success
                                 fail:(FailureBlock)fail
                                cache:(BOOL)isCache
                              showHUD:(BOOL)showHUD
{
    LMURLSessionTask *sessionTask=[[LMAFNetWorkAPI shareInstance] AFNet_HTTPRequest:params HttpTypes:HttpType_GET RequestURL:appendUrl success:success fail:fail cache:isCache];
    
    return sessionTask;}

+(LMURLSessionTask *)AFNet_POSTRequest:(NSDictionary *)params
                             appendUrl:(NSString *)appendUrl
                               success:(SuccessBlock)success
                                  fail:(FailureBlock)fail
                                 cache:(BOOL)isCache
                               showHUD:(BOOL)showHUD
{
    
    LMURLSessionTask *sessionTask=[[LMAFNetWorkAPI shareInstance] AFNet_HTTPRequest:params HttpTypes:HttpType_POST RequestURL:appendUrl success:success fail:fail cache:isCache];
    
    return sessionTask;
}
-(LMURLSessionTask *)uploadWithImage:(UIImage *)image url:(NSString *)url filename:(NSString *)filename name:(NSString *)name params:(NSDictionary *)params progress:(LMUploadProgress)progress success:(SuccessBlock)success fail:(FailureBlock)fail showHUD:(BOOL)showHUD
{
    LMLog(@"请求地址----%@\n    请求参数----%@",url,params);
    if (url==nil) {
        return nil;
    }
    
    if (showHUD==YES) {
    }
    
    //检查地址中是否有中文
    NSString *urlStr=[NSURL URLWithString:url]?url:[self strUTF8Encoding:url];
    
    AFHTTPSessionManager *manager=[self getAFManager];
    
    LMURLSessionTask *sessionTask = [manager POST:urlStr parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //压缩图片
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        
        NSString *imageFileName = filename;
        if (filename == nil || ![filename isKindOfClass:[NSString class]] || filename.length == 0) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            imageFileName = [NSString stringWithFormat:@"%@.jpg", str];
        }
        
        // 上传图片，以文件流的格式
        [formData appendPartWithFileData:imageData name:name fileName:imageFileName mimeType:@"image/jpeg"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        LMLog(@"上传进度--%lld,总进度---%lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        LMLog(@"上传图片成功=%@",responseObject);
        if (success) {
            success(responseObject,@"更新");
        }
        
        [[self tasks] removeObject:sessionTask];
        
        if (showHUD==YES)
        {
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        LMLog(@"error=%@",error);
        if (fail) {
            fail(error.domain);
        }
        
        [[self tasks] removeObject:sessionTask];
        
        if (showHUD==YES) {
        }
        
    }];
    
    
    if (sessionTask) {
        [[self tasks] addObject:sessionTask];
    }
    
    return sessionTask;
}
/**
 *  下载文件方法
 */
-(LMURLSessionTask *)downloadWithUrl:(NSString *)url
                           saveToPath:(NSString *)saveToPath
                             progress:(LMDownloadProgress )progressBlock
                              success:(SuccessBlock )success
                              failure:(FailureBlock )fail
                              showHUD:(BOOL)showHUD
{
    LMLog(@"请求地址----%@\n    ",url);
    if (url==nil) {
        return nil;
    }
    
    if (showHUD==YES) {
    }
    
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPSessionManager *manager = [self getAFManager];
    
    LMURLSessionTask *sessionTask = nil;
    
    sessionTask = [manager downloadTaskWithRequest:downloadRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        LMLog(@"下载进度--%.1f",1.0 * downloadProgress.completedUnitCount/downloadProgress.totalUnitCount);
        //回到主线程刷新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressBlock) {
                progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        if (!saveToPath) {
            
            NSURL *downloadURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            LMLog(@"默认路径--%@",downloadURL);
            return [downloadURL URLByAppendingPathComponent:[response suggestedFilename]];
            
        }else{
            return [NSURL fileURLWithPath:saveToPath];
            
        }
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        LMLog(@"下载文件成功");
        
        [[self tasks] removeObject:sessionTask];
        
        if (error == nil) {
            if (success) {
                success(nil,[filePath path]);//返回完整路径
            }
            
        } else {
            if (fail) {
                fail(error.domain);
            }
        }
        
        if (showHUD==YES) {
        }
        
    }];
    //开始启动任务
    [sessionTask resume];
    if (sessionTask)
    {
        [[self tasks] addObject:sessionTask];
    }
    
    return sessionTask;

}
#pragma mark---公用的私有化方法
-(LMURLSessionTask *)AFNet_HTTPRequest:(NSDictionary *)params
                             HttpTypes:(HttpType)httpType
                            RequestURL:(NSString *)requestURL
                               success:(SuccessBlock)success
                                  fail:(FailureBlock)fail
                                 cache:(BOOL)isCache
{
    //检查地址中是否有中文
    NSString *urlStr=[NSURL URLWithString:requestURL]?requestURL:[self strUTF8Encoding:requestURL];

    NSString * cacheUrl = [self urlDictToStringWithUrlStr:requestURL WithDict:params];
    
    //设置YYCache属性
    YYCache *cache = [[YYCache alloc] initWithName:SPHttpCache];
    
    cache.memoryCache.shouldRemoveAllObjectsOnMemoryWarning = YES;
    cache.memoryCache.shouldRemoveAllObjectsWhenEnteringBackground = YES;

    if (isCache) {
        id cacheData;
        //根据网址从Cache中取数据
        cacheData = [cache objectForKey:cacheUrl];
        if (cacheData != nil)
        {
            //将数据统一处理
            //判断是否为字典
            success(cacheData,@"缓存");
        }
        
    }
    
    if (![self requestBeforeJudgeConnect])
    {
        fail(@"没有网络");
        
        return nil;
    }

    AFHTTPSessionManager *manager=[self getAFManager];
    
    LMURLSessionTask *sessionTask=nil;
    
    switch (httpType)
    {
        case HttpType_GET:
        {
            sessionTask = [manager GET:urlStr parameters:params progress:^(NSProgress * _Nonnull downloadProgress)
            {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
                {
                    LMLog(@"请求结果=%@",responseObject);
                    if (success)
                    {
                        success(responseObject,@"更新");
                    }
                    if (isCache) {
                        [cache setObject:responseObject forKey:cacheUrl];
                        
                    }
                    [[self tasks] removeObject:sessionTask];
                
                 }
                failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
                {
                    LMLog(@"error=%@",error);
                    if (fail)
                    {
                        fail(error.domain);
                    }
                    [[self tasks] removeObject:sessionTask];
                }];
        }
        break;
        case HttpType_POST:
        {
            sessionTask = [manager POST:urlStr parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                LMLog(@"请求结果=%@",responseObject);
                if (success)
                {
                    success(responseObject,@"更新");
                }
                if (isCache)
                {
                    [cache setObject:responseObject forKey:cacheUrl];
                    
                }
                [[self tasks] removeObject:sessionTask];
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                LMLog(@"error=%@",error);
                if (fail)
                {
                    fail(error.domain);
                }
                
                [[self tasks] removeObject:sessionTask];
                
                
            }];
        }
            break;
        default:
            break;
    }
    return  sessionTask;
}

-(NSString *)urlDictToStringWithUrlStr:(NSString *)urlStr WithDict:(NSDictionary *)parameters
{
    if (!parameters)
    {
        return urlStr;
    }
    
    NSMutableArray *parts = [NSMutableArray array];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        //接收key
        NSString *finalKey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        //接收值
        NSString *finalValue = [obj stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        
        NSString *part =[NSString stringWithFormat:@"%@=%@",finalKey,finalValue];
        
        [parts addObject:part];
        
    }];
    
    NSString *queryString = [parts componentsJoinedByString:@"&"];
    
    queryString = queryString ? [NSString stringWithFormat:@"?%@",queryString] : @"";
    
    NSString *pathStr = [NSString stringWithFormat:@"%@?%@",urlStr,queryString];
    
    return pathStr;
}
#pragma mark  网络判断
-(BOOL)requestBeforeJudgeConnect
{
    struct sockaddr zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sa_len = sizeof(zeroAddress);
    zeroAddress.sa_family = AF_INET;
    SCNetworkReachabilityRef defaultRouteReachability =
    SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags =
    SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    if (!didRetrieveFlags) {
        printf("Error. Count not recover network reachability flags\n");
        return NO;
    }
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    BOOL isNetworkEnable  =(isReachable && !needsConnection) ? YES : NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible =isNetworkEnable;/*  网络指示器的状态： 有网络 ： 开  没有网络： 关  */
    });
    return isNetworkEnable;
}
#pragma makr - 开始监听网络连接

+ (void)startMonitoring
{
    // 1.获得网络监控的管理者
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    // 2.设置网络状态改变后的处理
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态改变了, 就会调用这个block
        switch (status)
        {
            case AFNetworkReachabilityStatusUnknown: // 未知网络
                LMLog(@"未知网络");
                [LMAFNetWorkAPI shareInstance].networkStats=StatusUnknown;
                
                break;
            case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
                LMLog(@"没有网络");
                [LMAFNetWorkAPI shareInstance].networkStats=StatusNotReachable;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
                LMLog(@"手机自带网络");
                [LMAFNetWorkAPI shareInstance].networkStats=StatusReachableViaWWAN;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
                
                [LMAFNetWorkAPI shareInstance].networkStats=StatusReachableViaWiFi;
                LMLog(@"WIFI--%d",[LMAFNetWorkAPI shareInstance].networkStats);
                break;
        }
    }];
    [mgr startMonitoring];
}
-(NSMutableArray *)tasks
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LMLog(@"创建数组");
        tasks = [[NSMutableArray alloc] init];
    });
    return tasks;
}

-(NSString *)strUTF8Encoding:(NSString *)str
{
    return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
}
-(AFHTTPSessionManager *)getAFManager{
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    AFHTTPSessionManager *manager  = [AFHTTPSessionManager manager];
    //manager.requestSerializer = [AFJSONRequestSerializer serializer];//设置请求数据为json
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//设置返回数据为json
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    manager.requestSerializer.timeoutInterval=10;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml",
                                                                              @"image/*"]];
    
    
    return manager;
    
}
@end
