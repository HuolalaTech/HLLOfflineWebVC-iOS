//
//  OfflineWebFileMgr.h
//  OfflineWebPackage
//
//  Created by 货拉拉 on 2021/8/11.
// 离线包相关的文件操作

#import "HLLOfflineWebConst.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 离线包本地文件管理类，主要在 HLLOfflineWebPackage 类内部逻辑调用
@interface HLLOfflineWebFileMgr : NSObject

+ (void)doZiptoNewFolder:(NSString *)bisName Zip:(NSString *)zipPath Result:(HLLOfflineWebResultBlock)resultBlock;
+ (void)deleteOldFolder:(NSString *)bisName;
+ (BOOL)doNewFolder2CurFolder:(NSString *)bisName;
+ (BOOL)deleteDiskCache;                     /// 删除所有离线包缓存
+ (BOOL)deleteDiskCache:(NSString *)bisName; /// 删除某个业务的离线包

+ (NSString *)getDiskCurVersion:(NSString *)bisName; /// 内部实现有IO操作读文件
+ (NSString *)getDiskNewVersion:(NSString *)bisName; /// 内部实现有IO操作读文件

+ (NSString *)getOfflineWebStorePath:(NSString *)bisName;
+ (NSString *)getPath:(NSString *)bisName;

@end

NS_ASSUME_NONNULL_END
