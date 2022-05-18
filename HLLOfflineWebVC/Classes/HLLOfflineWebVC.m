//
//  HLLOfflineWebVC.m
//  HLLOfflineWebVC
//
//  Created by 货拉拉 on 2021/11/2.
//

#import "HLLOfflineWebBisNameMatch.h"
#import "HLLOfflineWebDataReport.h"
#import "HLLOfflineWebPackage.h"
#import "HLLOfflineWebVC.h"

#ifdef DEBUG
#import "HLLOfflineWebDevTool.h"
#define DEBUG_CODE(code) code;
#else
#define DEBUG_CODE(code)
#endif

#define DefaultWebPackageConfig                                                                                        \
    @{@"predownloadlist" : @[ @"act3-offline-package-test", @"uappweb-offline" ], @"switch" : [NSNumber numberWithInt:0]}

@interface HLLOfflineWebVC ()

@property (nonatomic, strong) HLLOfflineWebDataReport *offwebDataReport; ///< 离线包数据上报
DEBUG_CODE(@property(nonatomic, strong) HLLOfflineWebDevTool *webDevTool;)

@end

@implementation HLLOfflineWebVC

- (void)viewDidLoad {
    //先初始化，以保证webvc父类的viewDidLoad处理执行了Load操作触发的相关回调执行setWebInfo 操作时，webDevTool是有效对象
    DEBUG_CODE(self.webDevTool = [[HLLOfflineWebDevTool alloc] init];)

    [super viewDidLoad];
    // Do any additional setup after loading the view.

    DEBUG_CODE([self.webDevTool attachToParentVc:self];)
}

- (HLLOfflineWebDataReport *)offwebDataReport {
    if (!_offwebDataReport) {
        _offwebDataReport = [[HLLOfflineWebDataReport alloc] init];
    }
    return _offwebDataReport;
}

- (BOOL)webview:(WKWebView *)webview shouldStartLoadWithRequest:(NSURLRequest *)request {
    NSString *newUrlStr = [HLLOfflineWebBisNameMatch filterWebURLString:request.URL.absoluteString
                                                             baseConfig:DefaultWebPackageConfig];
    if ([self doOffwebLogic:newUrlStr]) {
        return NO;
    }
    return YES;
}

- (BOOL)doOffwebLogic:(NSString *)url {
    NSString *bisName = [[HLLOfflineWebPackage getInstance] getOffWebBisName:url];
    self.offwebDataReport.bisName = bisName;
    [self.offwebDataReport notifyWebEvent:HLLOfflineWebDataReportEventWebviewStartLoad
                                      url:[NSURL URLWithString:url]
                                     code:0
                                   errMsg:@""];
    if (bisName != nil && [bisName length] > 0) {
        NSURL *fileUrl = [[HLLOfflineWebPackage getInstance] getFileURL:[NSURL URLWithString:url]];
        if (fileUrl == nil) {
            [self _hllofflineWebVc_load:[NSURL URLWithString:url]];
        } else {
            [self _hllofflineWebVc_load:fileUrl];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[HLLOfflineWebPackage getInstance]
                checkUpdate:bisName
                     result:^(HLLOfflineWebResultEvent result, NSString *message) {
                         if (result == HLLOfflineWebRefreshPackageNow) {
                             [self _hllofflineWebVc_load:[NSURL URLWithString:@"about:blank"]];
                             NSURL *fileUrl = [[HLLOfflineWebPackage getInstance] getFileURL:[NSURL URLWithString:url]];
                             [self _hllofflineWebVc_load:fileUrl];
                             NSLog(@"强制刷新");
                         } else if (result == HLLOfflineWebRefreshOnlineWebNow) {
                             if (self.webView.URL.isFileURL) {
                                 [self _hllofflineWebVc_load:[NSURL URLWithString:url]];
                             }
                             NSLog(@"配置走线上H5");
                         } else if (result == HLLOfflineWebRefreshPackageLater) {
                             NSLog(@"离线包解压成功，下次生效");
                         }
                     }];
        });

        return YES;
    }
    return NO;
}

- (void)_hllofflineWebVc_load:(NSURL *)url {
    if (url.isFileURL) {
        NSString *documentPath =
            NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *accessPath = [documentPath stringByAppendingString:@"/offlineWeb"];
        [self.webView loadFileURL:url allowingReadAccessToURL:[NSURL fileURLWithPath:accessPath]];
    } else {
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [super webView:webView didFinishNavigation:navigation];
    //离线包加载完成上报
    [self.offwebDataReport notifyWebEvent:HLLOfflineWebDataReportEventWebviewLoadSuccess
                                      url:webView.URL
                                     code:0
                                   errMsg:@"finish"];
}

//页面加载失败
- (void)webView:(WKWebView *)webView
    didFailProvisionalNavigation:(WKNavigation *)navigation
                       withError:(NSError *)error {
    [super webView:webView didFailProvisionalNavigation:navigation withError:error];
    //离线包加载失败上报
    [self.offwebDataReport notifyWebEvent:HLLOfflineWebDataReportEventWebviewLoadFail
                                      url:webView.URL
                                     code:error.code
                                   errMsg:error.description];
}

// 页面提交失败
- (void)webView:(WKWebView *)webView
    didFailNavigation:(null_unspecified WKNavigation *)navigation
            withError:(nonnull NSError *)error {
    [super webView:webView didFailNavigation:navigation withError:error];
    //离线包加载失败上报
    [self.offwebDataReport notifyWebEvent:HLLOfflineWebDataReportEventWebviewLoadFail
                                      url:webView.URL
                                     code:error.code
                                   errMsg:error.description];
}

// 准备加载页面
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {

    [self.offwebDataReport notifyWebEvent:HLLOfflineWebDataReportEventWebviewWillRequest
                                      url:webView.URL
                                     code:0
                                   errMsg:@""];

    DEBUG_CODE([self.webDevTool setWebInfo:webView.URL bisName:self.offwebDataReport.bisName];)
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
                      decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    [super webView:webView decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
    long statusCode = ((NSHTTPURLResponse *)navigationResponse.response).statusCode;
    [self.offwebDataReport notifyWebEvent:HLLOfflineWebDataReportEventWebviewReceiveResponse
                                      url:webView.URL
                                     code:statusCode
                                   errMsg:@""];
}

@end
