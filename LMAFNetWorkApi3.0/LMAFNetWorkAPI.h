//
//  LMAFNetWorkAPI.h
//  LMAFNetWorkApi3.0
//
//  Created by Lim on 16/5/25.
//  Copyright © 2016年 Lim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "YYCache.h"
typedef enum{
    StatusUnknown           = -1, //未知网络
    StatusNotReachable      = 0,    //没有网络
    StatusReachableViaWWAN  = 1,    //手机自带网络
    StatusReachableViaWiFi  = 2     //wifi
    
}NetworkStatus;

typedef enum{
    HttpType_GET           = 0, //GET请求
    HttpType_POST      = 1,    //POST
}HttpType;

typedef void (^SuccessBlock)(NSDictionary * requestDic, NSString * msg);
typedef void (^FailureBlock)(NSString *errorInfo);
typedef void( ^ LMUploadProgress)(int64_t bytesProgress,
                                  int64_t totalBytesProgress);
typedef void( ^ LMDownloadProgress)(int64_t bytesProgress,
                                    int64_t totalBytesProgress);
/**
 *  方便管理请求任务。执行取消，暂停，继续等任务.
 *  - (void)cancel，取消任务
 *  - (void)suspend，暂停任务
 *  - (void)resume，继续任务
 */
typedef NSURLSessionTask LMURLSessionTask;

@interface LMAFNetWorkAPI : NSObject
+(instancetype)shareInstance;
/**
 *  获取网络
 */
@property (nonatomic,assign)NetworkStatus networkStats;
/**
 *  开启网络监测
 */
+ (void)startMonitoring;
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
                showHUD:(BOOL)showHUD;

+(LMURLSessionTask *)AFNet_POSTRequest:(NSDictionary *)params
              appendUrl:(NSString *)appendUrl
                success:(SuccessBlock)success
                   fail:(FailureBlock)fail
                  cache:(BOOL)isCache
                showHUD:(BOOL)showHUD;
/**
 *  上传图片方法
 *  @param filename   图片的名称(如果不传则以当时间命名)
 *  @param name       上传图片时填写的图片对应的参数
 *  @param progress   上传进度
 */
-(LMURLSessionTask *)uploadWithImage:(UIImage *)image
                                  url:(NSString *)url
                             filename:(NSString *)filename
                                 name:(NSString *)name
                               params:(NSDictionary *)params
                             progress:(LMUploadProgress)progress
                              success:(SuccessBlock)success
                                 fail:(FailureBlock)fail
                              showHUD:(BOOL)showHUD;
/**
 *  下载文件方法
 */
-(LMURLSessionTask *)downloadWithUrl:(NSString *)url
                           saveToPath:(NSString *)saveToPath
                             progress:(LMDownloadProgress )progressBlock
                              success:(SuccessBlock )success
                              failure:(FailureBlock )fail
                              showHUD:(BOOL)showHUD;
@end
