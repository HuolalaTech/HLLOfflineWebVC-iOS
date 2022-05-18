//
//  WebviewDataReport.h
//  OfflineWebPackage
//
//  Created by 货拉拉 on 2021/8/11.
//离线包埋点功能

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 监控上报事件枚举定义
typedef NS_ENUM(NSInteger, HLLOfflineWebDataReportEvent) {
    HLLOfflineWebDataReportEventWebviewStartLoad       = 0,  /// WKWebView容器初始化URL，
    HLLOfflineWebDataReportEventWebviewLoadSuccess     = 1,  /// WKWebView didFinishNavigation事件触发，表示网络请求成功
    HLLOfflineWebDataReportEventWebviewLoadFail        = 2,  /// WKWebView didFailProvisionalNavigation和didFailNavigation触发，表示加载失败
    HLLOfflineWebDataReportEventWebviewWillRequest     = 3,  /// 每次发起请求前触发，首次打开或者容器内跳转其他URL都会触发
    HLLOfflineWebDataReportEventWebviewReceiveResponse = 4,  /// 收到http返回码时触发
};

/// 用于webview加载页面流程的相关监控数据上报，主要是为了监控离线包的相关性能数据
/// @note 但非离线包页面的加载对应的数据也会被上报 (这里是故意不进行过滤，需要统计线上加载和离线包加载的数据，已确认过)
@interface HLLOfflineWebDataReport : NSObject

/// 离线包业务的名称，在对应页面首次将要加载时进行赋值
/// @note 通常在 - (BOOL)webview:(WKWebView *)webview shouldStartLoadWithRequest:(NSURLRequest *)request
/// 回调中进行bisName的解析赋值
@property (nonatomic, copy) NSString *bisName;

/// 内部或外部使用的监控数据上报接口
/// @param event 上报事件类型
/// @param url 当前对应加载的url对象
/// @param errCode 错误码, 成功时传0即可
/// @param errMsg 错误描述信息，成功时传nil即可
- (void)notifyWebEvent:(HLLOfflineWebDataReportEvent)event
                   url:(NSURL *)url
                  code:(long)errCode
                errMsg:(NSString *_Nullable)errMsg;

@end

NS_ASSUME_NONNULL_END
