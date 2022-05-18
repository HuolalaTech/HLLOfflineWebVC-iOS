//
//  HLLOffWebDownload.h
//  HLLOfflineWebPackage
//
//  Created by 货拉拉 on 2021/8/19.
//离线包下载。可替换成其他下载SDK

#import "HLLOfflineWebConst.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 离线包文件下载管理类，仅供SDK内部逻辑调度使用，通常在 HLLOfflineWebPackage 类内部逻辑调用
/// @note 此类相关代码，若有不明可以咨询
@interface HLLOfflineWebDownloadMgr : NSObject

/// 下载离线包文件
/// @param bisName 业务名字符串
/// @param version 版本串
/// @param urlStr 下载的链接
/// @param resultBlock 结果回调
/// @param downloadSDKType 下载方式类型
- (void)downloadZip:(NSString *)bisName
            version:(NSString *)version
                url:(NSString *)urlStr
             result:(HLLOfflineWebResultBlock)resultBlock
    downloadSDKType:(HLLOfflineWebDownloadType)downloadSDKType;

@end

NS_ASSUME_NONNULL_END
