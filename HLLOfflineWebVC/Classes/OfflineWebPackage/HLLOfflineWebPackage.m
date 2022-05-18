//
//  OfflineWebPackage.m
//  OfflineWebPackage
//
//  Created by 货拉拉 on 2021/7/19.
//

#import "HLLOfflineWebDownloadMgr.h"
#import "HLLOfflineWebFileMgr.h"
#import "HLLOfflineWebFileUtil.h"
#import "HLLOfflineWebPackage+callbacks.h"
#import "HLLOfflineWebPackage.h"
#import <pthread.h>

#define CHECK_UPDATE_URL @"http://localhost:5555/offweb"

@interface HLLOfflineWebPackage () {
}

@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, strong) HLLOfflineWebDownloadMgr *downloadMgr;
@property (nonatomic, strong) NSMutableSet *disableBisList;

@end

@implementation HLLOfflineWebPackage

+ (HLLOfflineWebPackage *)getInstance {
    static dispatch_once_t onceToken;
    static HLLOfflineWebPackage *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)callbackMainThread:(HLLOfflineWebResultBlock)block Ret:(HLLOfflineWebResultEvent)ret Msg:(NSString *)msg {
    if ([[NSThread currentThread] isMainThread]) {
        if (block) {
            block(ret, msg);
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(ret, msg);
            }
        });
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _appVersion = @"0.0.0";
        self.downloadMgr = [[HLLOfflineWebDownloadMgr alloc] init];
        self.disalbleFlag = NO;
        self.disableBisList = [[NSMutableSet alloc] init];
    }
    return self;
}

- (NSString *)getOffWebBisName:(NSString *)str {
    if (self.disalbleFlag) {
        return nil;
    }

    NSURL *nsurl = [NSURL URLWithString:str];
    NSString *paramsStr = nsurl.query;
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionary];
    NSArray *paramArray = [paramsStr componentsSeparatedByString:@"&"];
    for (NSString *param in paramArray) {
        if (param && param.length) {
            NSArray *parArr = [param componentsSeparatedByString:@"="];
            if (parArr.count == 2) {
                [paramsDict setObject:parArr[1] forKey:parArr[0]];
            }
        }
    }
    if (paramsDict[@"offweb"] && [self.disableBisList containsObject:paramsDict[@"offweb"]]) {
        return nil;
    }

    return paramsDict[@"offweb"];
}

- (NSURL *)getFileURL:(NSURL *)webUrl {
    NSString *query = webUrl.query;
    NSString *host = webUrl.host;
    NSString *bisName = [self getOffWebBisName:webUrl.absoluteString];
    [HLLOfflineWebFileMgr doNewFolder2CurFolder:bisName];
    NSString *filePath = [HLLOfflineWebFileMgr getPath:bisName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        NSLog(@"offweb本地离线包不存在");
        self.logBlock(HLLOfflineWebLogLevelWarning, bisName, @"no local offweb file!");
        return nil;
    }

    filePath = [NSString stringWithFormat:@"file://%@", filePath];
    if (query && [query length] > 0 && ![query containsString:@"offweb_host="]) {
        query = [query stringByAppendingFormat:@"&offweb_host=%@", host];
    }
    if (webUrl.fragment) {
        filePath = [filePath stringByAppendingFormat:@"?%@#%@", query, webUrl.fragment]; //增加frament参数
    } else {
        //没有frament参数时就不拼
        filePath = [filePath stringByAppendingFormat:@"?%@", query];
    }

    return [NSURL URLWithString:filePath];
}

- (void)checkUpdate:(NSString *)bisName result:(HLLOfflineWebResultBlock)resultBlock {
    if (self.disalbleFlag) {
        resultBlock(HLLOfflineWebDisable, @"disable ALL offweb!");
        return;
    }

    if ([self.disableBisList containsObject:bisName]) {
        resultBlock(HLLOfflineWebDisable, @"disable current!");
        return;
    }

    if (!bisName || bisName.length == 0) {
        resultBlock(HLLOfflineWebParseError, @"bisName is nil");
        return;
    }

    NSMutableDictionary *reportdict = [NSMutableDictionary dictionary];
    [reportdict setValue:bisName forKey:@"bisName"];
        CFAbsoluteTime startQueryTime = CFAbsoluteTimeGetCurrent();
        NSString *offwebcurVer = [HLLOfflineWebFileMgr getDiskCurVersion:bisName];
        // 构造请求URL
        NSString *urlStr = [[NSString alloc] initWithFormat:@"%@?bisName=%@&os=iOS&offlineZipVer=%@&clientVersion=%@",
                                                            CHECK_UPDATE_URL, bisName, offwebcurVer, self.appVersion];
        if (self.env && [self.env length] > 0) {
            urlStr = [urlStr stringByAppendingFormat:@"&env=%@", self.env];
        }
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session
            dataTaskWithRequest:request
              completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                  // 解析数据
                  int queryCostTime = (CFAbsoluteTimeGetCurrent() - startQueryTime) * 1000;
                  [reportdict setObject:[NSNumber numberWithInt:queryCostTime] forKey:@"queryTime"];
                  [HLLOfflineWebFileMgr deleteOldFolder:bisName];
                  if (!error) {
                      [self parseCheckRspData:bisName data:data resultBlock:resultBlock reportdict:reportdict];
                  } else {
                      [self callbackMainThread:resultBlock Ret:HLLOfflineWebQueryError Msg:error.description];
                      self.logBlock(HLLOfflineWebLogLevelError, bisName,
                                    [NSString stringWithFormat:@"checkupate network err msg:%@", error.description]);
                      [reportdict setValue:[NSNumber numberWithInt:-1] forKey:@"queryResult"];
                      [reportdict setValue:error.description forKey:@"queryMsg"];
                      [self downloadDatareport:1
                                           msg:@"query fail,no download"
                                  downloadTime:0
                                          dict:reportdict]; //查询失败，无需下载
                  }
              }];

        [dataTask resume];
        self.logBlock(HLLOfflineWebLogLevelInfo, bisName, [NSString stringWithFormat:@"check update,url: %@", urlStr]);

    
}

//解析返回数据
- (void)parseCheckRspData:(NSString *)bisName
                     data:(NSData *)data
              resultBlock:(HLLOfflineWebResultBlock)resultBlock
               reportdict:(NSMutableDictionary *)reportdict {
    if (!data) {
        [self callbackMainThread:resultBlock Ret:HLLOfflineWebQueryError Msg:@"data = nil"];
        self.logBlock(HLLOfflineWebLogLevelError, bisName, @"data = nil");
        return;
    }

    NSString *rspStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    self.logBlock(HLLOfflineWebLogLevelInfo, bisName, rspStr);

    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSString *rspbisName = [dict objectForKey:@"bisName"];
    int result = [[dict objectForKey:@"result"] intValue];
    NSString *url = [dict objectForKey:@"url"];
    NSString *version = [dict objectForKey:@"version"]; // offlineZipVer
    int refreshMode = [[dict objectForKey:@"refreshMode"] intValue];

    [reportdict setValue:[NSNumber numberWithInt:0] forKey:@"queryResult"];
    [reportdict setValue:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] forKey:@"queryMsg"];

    if ([bisName isEqualToString:rspbisName]) {
        if (result > 0) {
            NSString *newVersion = [HLLOfflineWebFileMgr getDiskNewVersion:bisName];
            if ([newVersion isEqualToString:version]) {
                //如果本地已经有下载好的版本，不重复下载
                if (refreshMode == 0) {
                    [self callbackMainThread:resultBlock
                                         Ret:HLLOfflineWebRefreshPackageLater
                                         Msg:@"本地已有下好版本，下次生效"];
                    self.logBlock(HLLOfflineWebLogLevelInfo, bisName, @"本地已有下好版本，下次生效");
                } else if (refreshMode == 1) {
                    [self callbackMainThread:resultBlock
                                         Ret:HLLOfflineWebRefreshPackageNow
                                         Msg:@"本地已有下好版本，立刻生效"];
                    self.logBlock(HLLOfflineWebLogLevelInfo, bisName, @"本地已有下好版本，立刻生效");
                }

                [self downloadDatareport:1
                                     msg:@"NewFolder == online version"
                            downloadTime:0
                                    dict:reportdict]; //本地已有，无需下载
                return;
            }

            [self dowloadAndUnzip:bisName
                          Version:version
                              Url:url
                           result:^(HLLOfflineWebResultEvent result, NSString *msg) {
                               if (result == HLLOfflineWebUnzipSuccess) {
                                   if (refreshMode == 0) {
                                       [self callbackMainThread:resultBlock
                                                            Ret:HLLOfflineWebRefreshPackageLater
                                                            Msg:@"解压成功，下次生效"];
                                       self.logBlock(HLLOfflineWebLogLevelInfo, bisName, @"unzip success.act Next");
                                   } else if (refreshMode == 1) {
                                       [self callbackMainThread:resultBlock
                                                            Ret:HLLOfflineWebRefreshPackageNow
                                                            Msg:@"解压成功，马上生效"];
                                       self.logBlock(HLLOfflineWebLogLevelInfo, bisName, @"unzip success.act Now");
                                   }
                               } else {
                                   [self callbackMainThread:resultBlock Ret:result Msg:msg];
                                   self.logBlock(HLLOfflineWebLogLevelError, bisName, @"unzip fail!");
                               }
                           }
                             Dict:reportdict];

        } else if (result == 0) {
            self.logBlock(HLLOfflineWebLogLevelInfo, bisName, @"no new zip");
            [self callbackMainThread:resultBlock Ret:HLLOfflineWebNoUpdate Msg:@"线上无新包"];
            [self downloadDatareport:1 msg:@"no new zip" downloadTime:0 dict:reportdict]; //本地已有，无需下载
        } else if (result == -1) {
            [HLLOfflineWebFileMgr deleteDiskCache:bisName];
            self.logBlock(HLLOfflineWebLogLevelWarning, bisName, @"disabel offweb,delete local folder");
            [self callbackMainThread:resultBlock Ret:HLLOfflineWebRefreshOnlineWebNow Msg:@"disable offlineWeb"];
            [self downloadDatareport:1 msg:@"disable offweb" downloadTime:0 dict:reportdict]; //本地已有，无需下载
        }
    } else {
        [self callbackMainThread:resultBlock Ret:HLLOfflineWebQueryError Msg:@"bisName is not right"];
        self.logBlock(HLLOfflineWebLogLevelError, bisName, @"bisName is not right");
        [self downloadDatareport:1 msg:@"bisName is not right" downloadTime:0 dict:reportdict]; //本地已有，无需下载
    }
}

- (void)dowloadAndUnzip:(NSString *)bisName
                Version:(NSString *)version
                    Url:(NSString *)urlStr
                 result:(HLLOfflineWebResultBlock)resultBlock
                   Dict:(NSMutableDictionary *)reportdict {
    __weak typeof(self) weakSelf = self;
    CFAbsoluteTime startDownloadTime = CFAbsoluteTimeGetCurrent();
    [self.downloadMgr
            downloadZip:bisName
                version:version
                    url:urlStr
                 result:^(HLLOfflineWebResultEvent result, NSString *msg) {
                     __strong typeof(self) strongself = weakSelf;
                     int downloadCostTime = (int)(CFAbsoluteTimeGetCurrent() - startDownloadTime) * 1000;
                     if (result == HLLOfflineWebDownloadSuccess) {
                         NSString *zipPath = msg;
                         int fileSize = [HLLOfflineWebFileUtil getFileSize:zipPath];
                         CFAbsoluteTime startUnZipTime = CFAbsoluteTimeGetCurrent();
                         [HLLOfflineWebFileMgr
                             doZiptoNewFolder:bisName
                                          Zip:zipPath
                                       Result:^(HLLOfflineWebResultEvent zipResult, NSString *zipMsg) {
                                           if (!strongself) {
                                               return;
                                           }

                                           strongself.logBlock(
                                               zipResult == HLLOfflineWebUnzipSuccess ? HLLOfflineWebLogLevelInfo
                                                                                       : HLLOfflineWebLogLevelError,
                                               bisName, [NSString stringWithFormat:@"zip result:%@", zipMsg]);
                                           int unzipCostTime =
                                               (int)(CFAbsoluteTimeGetCurrent() - startUnZipTime) * 1000;
                                           [reportdict setValue:[NSNumber numberWithInt:(zipResult ==
                                                                                         HLLOfflineWebUnzipSuccess)
                                                                                            ? 0
                                                                                            : -1]
                                                         forKey:@"unzipResult"];
                                           [reportdict setValue:[NSNumber numberWithInt:unzipCostTime]
                                                         forKey:@"unzipTime"];
                                           [reportdict setValue:zipMsg forKey:@"unzipMsg"];
                                           [reportdict setValue:[NSNumber numberWithInt:fileSize] forKey:@"zipSize"];

                                           [strongself downloadDatareport:0
                                                                      msg:@"download success"
                                                             downloadTime:downloadCostTime
                                                                     dict:reportdict];
                                           if (strongself.downloadSDKType == HLLOfflineWebDownloadTypeSystemAPI) {
                                               NSFileManager *fileManager = [NSFileManager defaultManager];
                                               [fileManager removeItemAtPath:zipPath error:nil]; // del zip包
                                           } else {
                                               // [weakSelf.downloadMgr delSDKZip:urlStr];
                                           }
                                           strongself.logBlock(HLLOfflineWebLogLevelInfo, bisName, @"del zip");
                                           resultBlock(zipResult, zipMsg);
                                       }];
                     } else {
                         self.logBlock(HLLOfflineWebLogLevelError, bisName, @"download fail!");
                         resultBlock(result, msg);
                         [self downloadDatareport:-1
                                              msg:@"download fail"
                                     downloadTime:downloadCostTime
                                             dict:reportdict];
                     }
                 }
        downloadSDKType:self.downloadSDKType]; //下载sdk选择
}

- (void)downloadDatareport:(int)result
                       msg:(NSString *)msg
              downloadTime:(int)downloadTime
                      dict:(NSMutableDictionary *)reportdict {
    [reportdict setValue:[NSNumber numberWithInt:result] forKey:@"downloadResult"];
    [reportdict setValue:[NSNumber numberWithInt:downloadTime] forKey:@"downloadTime"];
    [reportdict setValue:msg forKey:@"downloadMsg"];
    if (result == -1 || result == 1) {
        [reportdict setValue:[NSNumber numberWithInt:1] forKey:@"unzipResult"];
        [reportdict setValue:[NSNumber numberWithInt:0] forKey:@"unzipTime"];
        [reportdict setValue:@"" forKey:@"unzipMsg"];
        [reportdict setValue:[NSNumber numberWithInt:0] forKey:@"zipSize"];
        self.reportBlock(@"offweb_cost_time", reportdict);
    } else if (result == 0) {
        self.reportBlock(@"offweb_cost_time", reportdict);
    }
}

- (void)addToDisableList:(NSString *)bisName {
    [self.disableBisList addObject:bisName];
}

#pragma mark - blocks safe lazy load

- (HLLOfflineWebLogBlock)logBlock {
    if (!_logBlock) {
        _logBlock = ^(HLLOfflineWebLogLevel level, NSString *keyword, NSString *message) {
            NSLog(@"offweblog:%d:%@:%@", (int)level, keyword, message);
        };
    }
    return _logBlock;
}
- (HLLOfflineWebReportBlock)reportBlock {
    if (!_reportBlock) {
        _reportBlock = ^(NSString *event, NSDictionary *dict) {
            NSLog(@"report event: %@ dict:%@", event, dict);
        };
    }
    return _reportBlock;
}

- (HLLOfflineWebMonitorBlock)monitorBlock {
    if (!_monitorBlock) {
        _monitorBlock = ^(HLLOfflineWebMonitorType type, NSString *key, CGFloat value, NSDictionary *lables) {
            NSLog(@"offwebMonitor:%d:%@:%f", (int)type, key, value);
        };
    }
    return _monitorBlock;
}

@end
