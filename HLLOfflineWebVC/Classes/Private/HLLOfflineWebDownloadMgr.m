//
//  HLLOffWebDownload.m
//  HLLOfflineWebPackage
//
//  Created by 货拉拉 on 2021/8/19.
//

#import "HLLOfflineWebDownloadMgr.h"
#import "HLLOfflineWebPackage+callbacks.h"

/// 内部用的便捷的log方法
NS_INLINE void HLLOfflineWebDownloadMgr_offlineWebLog(HLLOfflineWebLogLevel level, NSString *keyword, NSString *message) {
    [HLLOfflineWebPackage getInstance].logBlock(level, keyword, message);
};

@interface HLLOfflineWebDownloadMgr () {
}

@property (nonatomic, strong) NSMutableDictionary *downloadingDict;
@end

@implementation HLLOfflineWebDownloadMgr

- (instancetype)init {
    self = [super init];
    if (self) {
        self.downloadingDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)downloadZip:(NSString *)bisName
            version:(NSString *)version
                url:(NSString *)urlStr
             result:(HLLOfflineWebResultBlock)resultBlock
    downloadSDKType:(HLLOfflineWebDownloadType)downloadSDKType {

    [self downloadUseAPI:bisName version:version url:urlStr result:resultBlock];
}

- (void)downloadUseAPI:(NSString *)bisName
               version:(NSString *)version
                   url:(NSString *)urlStr
                result:(HLLOfflineWebResultBlock)resultBlock {
    if (!bisName || bisName.length == 0) {
        resultBlock(HLLOfflineWebParseError, @"bisName is nil");
        return;
    }

    if (!urlStr || [urlStr length] == 0) {
        resultBlock(HLLOfflineWebParseError, @"url is invalid");
        return;
    }

    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    if ([self.downloadingDict objectForKey:urlStr] == nil) {
        self.downloadingDict[urlStr] = @"1";
        NSURLSessionDownloadTask *downloadTask =
            [session downloadTaskWithRequest:request
                           completionHandler:^(NSURL *_Nullable location, NSURLResponse *_Nullable response,
                                               NSError *_Nullable error) {
                               [self.downloadingDict removeObjectForKey:urlStr];
                               if (!error) {
                                   HLLOfflineWebDownloadMgr_offlineWebLog(
                                       HLLOfflineWebLogLevelInfo, bisName,
                                       [NSString stringWithFormat:@"download sucess:%@", urlStr]);
                                   resultBlock(HLLOfflineWebDownloadSuccess, [location path]);
                               } else {
                                   HLLOfflineWebDownloadMgr_offlineWebLog(
                                       HLLOfflineWebLogLevelInfo, bisName,
                                       [NSString stringWithFormat:@"download sucess:%@", urlStr]);
                                   resultBlock(HLLOfflineWebDownloadError, error.description);
                               }
                           }];
        [downloadTask resume];

    } else {
        HLLOfflineWebDownloadMgr_offlineWebLog(HLLOfflineWebLogLevelWarning, bisName,
                                               @"此版本已在下载中，不再重复下载");
        resultBlock(HLLOfflineWebDownloading, @"offweb is downloading");
    }
}

@end
