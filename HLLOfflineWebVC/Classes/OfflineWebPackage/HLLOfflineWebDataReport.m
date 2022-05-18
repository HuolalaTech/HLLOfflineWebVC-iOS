//
//  WebviewDataReport.m
//  OfflineWebPackage
//
//  Created by 货拉拉 on 2021/8/11.
//

#import "HLLOfflineWebDataReport.h"
#import "HLLOfflineWebPackage+callbacks.h"

@interface HLLOfflineWebDataReport ()

@property (nonatomic, strong) NSURL *originURL;
@property (nonatomic, assign) CFAbsoluteTime startQueryTime; ///< webview启动时间戳
@property (nonatomic, assign) CFAbsoluteTime willQueryTime; ///< webview发起网络请求时间戳。因为wekit初始化有时间，所以和startQuery有相差
@property (nonatomic, assign) NSInteger httpResponseCode;

@end

@implementation HLLOfflineWebDataReport

- (instancetype)init {
    self = [super init];
    if (self) {
        self.startQueryTime = 0;
        self.willQueryTime = 0;
    }
    return self;
}

- (void)notifyWebEvent:(HLLOfflineWebDataReportEvent)event
                   url:(NSURL *)url
                  code:(long)errCode
                errMsg:(NSString *)errMsg {

    //全局开关暂停时，不做任何上报
    if ([HLLOfflineWebPackage getInstance].disalbleFlag) {
        return;
    }

    if (event == HLLOfflineWebDataReportEventWebviewStartLoad) {
        self.startQueryTime = CFAbsoluteTimeGetCurrent();
    } else if (event == HLLOfflineWebDataReportEventWebviewWillRequest) {
        self.willQueryTime = CFAbsoluteTimeGetCurrent();
        self.originURL = url;
    } else if (event == HLLOfflineWebDataReportEventWebviewReceiveResponse) {
        //暂存http返回码
        self.httpResponseCode = errCode;
    } else if (event == HLLOfflineWebDataReportEventWebviewLoadSuccess ||
               event == HLLOfflineWebDataReportEventWebviewLoadFail) {
        if (self.originURL == nil) {
            return;
        }

        NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
        [dataDict setObject:self.originURL.absoluteString forKey:@"url"];
        NSString *simpleUrl =
            [NSString stringWithFormat:@"%@://%@%@", self.originURL.scheme, self.originURL.host, self.originURL.path];
        if ([self.originURL isFileURL]) {
            simpleUrl = @"file:///cur/index.html";
        }
        [dataDict setObject:simpleUrl forKey:@"simpleUrl"];

        // CFAbsoluteTimeGetCurrent()返回的时间戳单位是: 微秒
        int costTime = 0;
        if (self.startQueryTime != 0) {
            // webview容器首次打开和加载H5开始
            costTime = (CFAbsoluteTimeGetCurrent() - self.startQueryTime) * 1000;
        } else if (self.willQueryTime != 0) {
            //页面内跳转H5计时
            costTime = (CFAbsoluteTimeGetCurrent() - self.willQueryTime) * 1000;
        }
        self.startQueryTime = 0; //时间戳计数清零
        self.willQueryTime = 0;

        [dataDict setObject:[NSNumber numberWithInt:costTime] forKey:@"loadTime"];
        [dataDict setObject:[NSNumber numberWithInt:(event == HLLOfflineWebDataReportEventWebviewLoadSuccess) ? 0 : -1]
                     forKey:@"loadResult"]; // 0成功，-1 失败
        [dataDict setObject:errMsg ?: @"" forKey:@"errMsg"];
        [dataDict setObject:[NSNumber numberWithLong:errCode] forKey:@"errCode"];
        [dataDict setObject:[NSNumber numberWithLong:self.httpResponseCode] forKey:@"httpCode"];
        if ([self.originURL isFileURL]) {
            [dataDict setObject:[NSNumber numberWithInt:1] forKey:@"isOffweb"];
        } else {
            [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isOffweb"];
        }
        [dataDict setObject:self.bisName ?: @"" forKey:@"bisName"];

        [HLLOfflineWebPackage getInstance].reportBlock(@"offweb_client_load_time", dataDict);

        //后续为实时监控上报数据。
        NSString *fragment = self.originURL.fragment;
        NSString *appendstring = nil;
        if (fragment != nil && [fragment length] > 0) {
            NSRange range;
            range = [fragment rangeOfString:@"?"];
            if (range.location == NSNotFound) {
                appendstring = fragment;
            } else {
                appendstring = [fragment substringToIndex:range.location];
            }
        }
        NSString *urlWithFragment = simpleUrl;
        if (appendstring != nil && [appendstring length] != 0) {
            urlWithFragment = [urlWithFragment stringByAppendingFormat:@"#%@", appendstring];
        }

        NSMutableDictionary *monitorLables = [NSMutableDictionary dictionary];
        [monitorLables setObject:self.originURL.scheme ?: @"" forKey:@"scheme"];
        [monitorLables setObject:urlWithFragment ?: @"" forKey:@"url"];
        [monitorLables setObject:self.bisName ?: @"" forKey:@"bisName"];

        if (event == HLLOfflineWebDataReportEventWebviewLoadSuccess && self.httpResponseCode >= 400) {
            // 404错误会统计到网络成功里
            [monitorLables setObject:[NSString stringWithFormat:@"HTTP%ld", self.httpResponseCode] forKey:@"result"];
        } else {
            [monitorLables setObject:[NSString stringWithFormat:@"%ld", errCode] forKey:@"result"];
        }

        [HLLOfflineWebPackage getInstance].monitorBlock(HLLOfflineWebMonitorTypeSummary, @"webviewLoadTime",
                                                        costTime * 1.0, monitorLables);

        self.httpResponseCode = 0; // http返回码清零
    }
}

@end
