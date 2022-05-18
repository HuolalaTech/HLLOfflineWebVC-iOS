//
//  HLLOfflineWebConfig.h
//  HLLOfflineWebVC
//
//  Created by 货拉拉 on 2021/11/2.
//离线包初始化。
// 1）包含实施监控、数据埋点、日志等功能实现
// 2）包含离线包的功能配置，比如是否降级，需要启动时下载的离线包等配置
#import "HLLOfflineWebConst.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// MARK: 配置信息字典的相关Key定义

/// 子配置项keys
FOUNDATION_EXTERN NSString *const kHLLOfflineWebConfigKey_switch;
FOUNDATION_EXTERN NSString *const kHLLOfflineWebConfigKey_disablelist;
FOUNDATION_EXTERN NSString *const kHLLOfflineWebConfigKey_predownloadList;
FOUNDATION_EXTERN NSString *const kHLLOfflineWebConfigKey_downloadSdk;

#pragma mark -
@interface HLLOfflineWebConfig : NSObject

/// 返回包含了一个默认配置信息的字典
/// @note return @{@"switch": @(0), @"predownloadlist": @[], @"downloadsdk": @(0)}
/// @note 外部取值或修改数据可以用上述定义的kHLLOfflineWebConfigKey系列key值读取或修改数据，注意字典的层级结构
+ (NSDictionary *)defaultOffWebConfigDic;

/// 离线包初始化函数
/// @param offwebConfigDict 离线包配置参数, 可通过 defaultOffWebConfigDic
/// 方法获取默认配置基础上修改相关默认配置项值后传入
/// @param logBlock 日志block，需要外部设置日志的具体处理
/// @param reportBlock 埋点block，需要外部设置埋点的具体处理
/// @param monitorBlock 加载流程、信息的监控回调
/// @param env 对应app运行的环境串，如 stg | pre | prd ，为nil时按prd的流程处理
/// @param appVersion 当前集成的宿主app的版本串，可以直接从plist文件中读取传入即可
+ (void)setInitalParam:(NSDictionary *)offwebConfigDict
              logBlock:(HLLOfflineWebLogBlock)logBlock
           reportBlock:(HLLOfflineWebReportBlock)reportBlock
          monitorBlock:(HLLOfflineWebMonitorBlock)monitorBlock
                   env:(NSString *_Nullable)env
            appversion:(NSString *)appVersion;

/// 离线包预下载
/// @param offwebConfigDict 离线包配置参数, 可通过 defaultOffWebConfigDic
/// 方法获取默认配置基础上修改相关默认配置项值后传入
///  @note 只有当配置信息中对应的switch的值为1时，调用此方法才有效，否则内部会忽略预下载处理
///  @note 调用此函数前最好先调用上面的 setInital 接口，设置相关log回调
+ (void)predownloadOffWebPackage:(NSDictionary *)offwebConfigDict;

@end

NS_ASSUME_NONNULL_END
