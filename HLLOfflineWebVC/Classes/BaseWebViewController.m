//

#import "BaseWebViewController.h"
#import <HLLOfflineWebVC/HLLOfflineWebDataReport.h>
#import <HLLOfflineWebVC/HLLOfflineWebFileMgr.h>
#import <HLLOfflineWebVC/HLLOfflineWebPackage.h>

#define GetScreenWidth [[UIScreen mainScreen] bounds].size.width

@interface BaseWebViewController ()

@property (nonatomic, weak, readwrite) WKWebView *webView;
@property (nonatomic, strong, readwrite) WKUserContentController *userContentController;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *orginUrl;

@end

@implementation BaseWebViewController

- (instancetype)initWithUrl:(NSString *)url {
    self = [super init];
    if (self) {
        self.orginUrl = url;
        self.url = url;
    }
    return self;
}

- (void)load:(NSURL *)url {
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark - WKNavigationDelegate
// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"webView didReceiveServerRedirectForProvisionalNavigation ");
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
                      decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    long statusCode = ((NSHTTPURLResponse *)navigationResponse.response).statusCode;

    NSLog(@"webView decidePolicyForNavigationResponse %ld，%@", statusCode,
          navigationResponse.response.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    NSLog(@"webView decidePolicyForNavigationAction %@", navigationAction.request.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // H5加载完成上报
    NSLog(@"webView didFinishNavigation ");
}

// 页面提交失败
- (void)webView:(WKWebView *)webView
    didFailNavigation:(null_unspecified WKNavigation *)navigation
            withError:(nonnull NSError *)error {
    NSLog(@"webView didFailNavigation,%ld", error.code);
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView
    didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation
                       withError:(NSError *)error {
    NSLog(@"webView didFailProvisionalNavigation %ld,", (long)error.code);
}

#pragma mark-- WKUIDelegate
// 显示一个按钮。点击后调用completionHandler回调
- (void)webView:(WKWebView *)webView
    runJavaScriptAlertPanelWithMessage:(NSString *)message
                      initiatedByFrame:(WKFrameInfo *)frame
                     completionHandler:(void (^)(void))completionHandler {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          completionHandler();
                                                      }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 显示两个按钮，通过completionHandler回调判断用户点击的确定还是取消按钮
- (void)webView:(WKWebView *)webView
    runJavaScriptConfirmPanelWithMessage:(NSString *)message
                        initiatedByFrame:(WKFrameInfo *)frame
                       completionHandler:(void (^)(BOOL))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          completionHandler(YES);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          completionHandler(NO);
                                                      }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 显示一个带有输入框和一个确定按钮的，通过completionHandler回调用户输入的内容
- (void)webView:(WKWebView *)webView
    runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
                              defaultText:(NSString *)defaultText
                         initiatedByFrame:(WKFrameInfo *)frame
                        completionHandler:(void (^)(NSString *_Nullable))completionHandler {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField){
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          completionHandler(alertController.textFields.lastObject.text);
                                                      }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)viewDidLoad {
    double beginTime = [[NSDate date] timeIntervalSince1970] * 1000;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    WKWebViewConfiguration *webViewConfiguration = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    webViewConfiguration.userContentController = userContentController;
    NSString *loadUrlString = nil;
    NSString *documentPath =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    loadUrlString = [NSString stringWithFormat:@"%@/yanagi-test-1-v1/index.html", documentPath];
    NSLog(@"webview inital start");

    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:webViewConfiguration];
    self.webView = webView;
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self.view addSubview:webView];
    [self.webView.configuration.preferences setValue:@YES forKey:@"allowFileAccessFromFileURLs"];
    // 可控制是否加载当前URL
    if (![self webview:_webView
            shouldStartLoadWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]]) {
        return;
    }
    [self load:[NSURL URLWithString:self.url]];
    double endTime = [[NSDate date] timeIntervalSince1970] * 1000;
    NSLog(@"webview inital finish");
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber *initCost = [NSNumber numberWithDouble:(endTime - beginTime)];
    [userDefault setObject:initCost forKey:@"WebViewinitCost"];
}

- (void)dealloc {
    [self.userContentController removeScriptMessageHandlerForName:@"heraldAppBridge"];
}

- (BOOL)webview:(WKWebView *)webview shouldStartLoadWithRequest:(NSURLRequest *)request {
    return YES;
}
@end
