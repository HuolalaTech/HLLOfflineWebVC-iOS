//
//  HLLOfflineWebConst.h
//  Pods
//
//  Created by 货拉拉 on 2022/3/11.
//

#ifndef HLLOfflineWebConst_h
#define HLLOfflineWebConst_h

#pragma mark - 常量定义

/// 对应的一些操作事件或状态定义
typedef NS_ENUM(NSInteger, HLLOfflineWebResultEvent) {
    HLLOfflineWebDisable               = -17,  ///< 暂时禁用了离线包
    HLLOfflineWebParseError            = -16,  ///< 相关数据解析失败
    HLLOfflineWebQueryError            = -14,  ///< 检查更新出错
    HLLOfflineWebDownloadError         = -13,  ///<  下载出错 -
    HLLOfflineWebUnzipError            = -12,  ///< 解压出错
    HLLOfflineWebDownloadCancel        = -1,   ///< 下载取消 - 未用到
    HLLOfflineWebDownloading           = -4,   ///< 处于下载中
    HLLOfflineWebUnzipSuccess          = 0,    ///< 解压成功

    HLLOfflineWebRefreshPackageLater   = 1,    ///< 离线包已下载，下次生效
    HLLOfflineWebRefreshPackageNow     = 2,    ///< 离线包已下载，马上生效
    HLLOfflineWebRefreshOnlineWebNow   = 3,    ///< 刷新线上页面,即若当前是离线包加载，收到此事件时应该马上刷新加载线上页面

    HLLOfflineWebNoUpdate              = 10,   ///< 检查离线包更新，返回线上无更新
    HLLOfflineWebDownloadSuccess       = 11,   ///< 离线包下载成功
};

/// 对应logBlock中的传递的level值，上层业务需要关注此回调的具体值
typedef NS_ENUM(NSInteger, HLLOfflineWebLogLevel) {
    HLLOfflineWebLogLevelError         = 0,   ///< 错误日志级别
    HLLOfflineWebLogLevelWarning       = 1,   ///<警告日志级别
    HLLOfflineWebLogLevelInfo          = 2,   ///< 信息日志级别
    HLLOfflineWebLogLevelDebug         = 3,   ///< 调试日志级别
};

/// 对应monitorBlock中传递的type值，上层业务需要关注此回调的具体值
typedef NS_ENUM(NSInteger, HLLOfflineWebMonitorType) {
    HLLOfflineWebMonitorTypeCounter    = 0,  ///<计数型监控
    HLLOfflineWebMonitorTypeSummary    = 1,  ///<求和型监控
};

/// 下载SDK类型
typedef NS_ENUM(NSInteger, HLLOfflineWebDownloadType) {
    HLLOfflineWebDownloadTypeSystemAPI = 0,  ///<系统API下载方式。
};

#pragma mark - 回调定义： 外部和内部都会用到

/// 相关操作的回调block
typedef void (^HLLOfflineWebResultBlock)(HLLOfflineWebResultEvent event, NSString *desc);

/// 定义外部自定义的日志回调block |
/// 参数与当前argus日志库的调用参数保持一致，上层注意区分level值与日志库中的定义是否一致，若不一致则需要自行映射转换
typedef void (^HLLOfflineWebLogBlock)(HLLOfflineWebLogLevel level, NSString *keyword, NSString *message);

/// 定义外部自定义的埋点数据上报回调block | 参数与当前神策SDK上报时的调用参数保持一致
typedef void (^HLLOfflineWebReportBlock)(NSString *event, NSDictionary *dict);

/// 定义外部自定义的监控上报回调block | 参数与argus日志库中的实时上报的调用参数保持一致，type用来区分指标类型
typedef void (^HLLOfflineWebMonitorBlock)(HLLOfflineWebMonitorType type, NSString *key, CGFloat value,
                                          NSDictionary *lables);

#endif /* HLLOfflineWebConst_h */
