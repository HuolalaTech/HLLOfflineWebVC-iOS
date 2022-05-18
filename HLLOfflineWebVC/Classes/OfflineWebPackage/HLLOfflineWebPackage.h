//
//  OfflineWebPackage.h
//  OfflineWebPackage
//
//  Created by 货拉拉 on 2021/7/19.
// 离线包核心模块。包含离线包查询、下载、更新、降级功能。

#import "HLLOfflineWebConst.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 离线包功能对外接入的主类
@interface HLLOfflineWebPackage : NSObject
@property (nonatomic, copy) NSString *env; ///< 设置后端环境，debug需要，release包不需要设置
@property (nonatomic, assign) HLLOfflineWebDownloadType downloadSDKType; ///< 设置下载sdk方式，默认不启用断点续传
@property (nonatomic, assign) BOOL disalbleFlag;///< 全局屏蔽，开启后离线包的更新和加载逻辑暂时实效。

///获取单例接口
/// @return 返回单例对象
+ (HLLOfflineWebPackage *)getInstance;

/// 设置客户端版本
/// @param version 客户端版本号
- (void)setAppVersion:(NSString *)version;

/// 提取当前url对应的本地离线包业务名
/// @param urlStr 在线网页的url串
/// @return 离线业务名，没有时返回nil
- (NSString *_Nullable)getOffWebBisName:(NSString *)urlStr;

/// 获取当前url对应的本地离线包中的index.html路径
/// @param webUrl 在线网页的url
/// @return 对应的本地index文件路径，没有时返回nil
- (NSURL *_Nullable)getFileURL:(NSURL *)webUrl;

/// 离线包更新检查接口
/// @param bisName 离线包业务名
/// @param resultBlock 结果回调
- (void)checkUpdate:(NSString *)bisName result:(HLLOfflineWebResultBlock)resultBlock;

/// 将某个离线加入黑名单，暂时禁用更新和加载
/// @param bisName 离线包业务名
- (void)addToDisableList:(NSString *)bisName;

@end

NS_ASSUME_NONNULL_END
