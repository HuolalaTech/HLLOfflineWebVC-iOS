
///基于WKWebview封装的简单Webview容器
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface BaseWebViewController : UIViewController <WKUIDelegate, WKNavigationDelegate>
- (instancetype)initWithUrl:(NSString *)url;
@property (nonatomic, weak, readonly) WKWebView *webView;

@end

NS_ASSUME_NONNULL_END
