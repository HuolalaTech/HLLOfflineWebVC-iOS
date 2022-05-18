//
//  HLLOfflineWebConfig.m
//  HLLOfflineWebVC
//
//  Created by 货拉拉 on 2021/11/2.
//

#import "HLLOfflineWebConfig.h"
#import "HLLOfflineWebPackage+callbacks.h"
/// 子配置项keys
NSString *const kHLLOfflineWebConfigKey_switch = @"switch";
NSString *const kHLLOfflineWebConfigKey_disablelist = @"disablelist";
NSString *const kHLLOfflineWebConfigKey_predownloadList = @"predownloadlist";
NSString *const kHLLOfflineWebConfigKey_downloadSdk = @"downloadsdk";

@implementation HLLOfflineWebConfig

+ (NSDictionary *)defaultOffWebConfigDic {
    return @{
        kHLLOfflineWebConfigKey_switch : @(0),
        kHLLOfflineWebConfigKey_disablelist : @[].mutableCopy,
        kHLLOfflineWebConfigKey_predownloadList : @[].mutableCopy,
        kHLLOfflineWebConfigKey_downloadSdk : @(0)
    };
}

+ (void)setInitalParam:(NSDictionary *)offwebConfigDict
              logBlock:(HLLOfflineWebLogBlock)logBlock
           reportBlock:(HLLOfflineWebReportBlock)reportBlock
          monitorBlock:(HLLOfflineWebMonitorBlock)monitorBlock
                   env:(NSString *)env
            appversion:(NSString *)appVersion {
    // switch值为1时，打开
    if ([offwebConfigDict isKindOfClass:[NSDictionary class]] && offwebConfigDict.count > 0) {
        if ([offwebConfigDict[kHLLOfflineWebConfigKey_switch] boolValue]) {
            [HLLOfflineWebPackage getInstance].disalbleFlag = NO;
            [HLLOfflineWebPackage getInstance].env = env;
            [[HLLOfflineWebPackage getInstance] setAppVersion:appVersion];
            [HLLOfflineWebPackage getInstance].logBlock = logBlock;
            [HLLOfflineWebPackage getInstance].reportBlock = reportBlock;
            [HLLOfflineWebPackage getInstance].monitorBlock = monitorBlock;
            [HLLOfflineWebPackage getInstance].downloadSDKType =
                [offwebConfigDict[kHLLOfflineWebConfigKey_downloadSdk] intValue];
            NSArray *disableList = offwebConfigDict[kHLLOfflineWebConfigKey_disablelist];
            for (int i = 0; i < [disableList count]; i++) {
                [[HLLOfflineWebPackage getInstance] addToDisableList:disableList[i]];
            }
        } else {
            [HLLOfflineWebPackage getInstance].disalbleFlag = YES;
        }
    } else {
        NSLog(@"[!] => offwebConfig setInital do nothing, because offwebConfigParams is: %@", offwebConfigDict);
    }
}

+ (void)predownloadOffWebPackage:(NSDictionary *)offwebConfigDict {
    // switch值为1时，打开网络请求日志打点功能.
    if ([offwebConfigDict isKindOfClass:[NSDictionary class]] && offwebConfigDict.count > 0) {
        if ([offwebConfigDict[kHLLOfflineWebConfigKey_switch] boolValue]) {
            NSArray *downloadList = offwebConfigDict[kHLLOfflineWebConfigKey_predownloadList];
            for (int i = 0; i < [downloadList count]; i++) {
                [[HLLOfflineWebPackage getInstance] checkUpdate:downloadList[i]
                                                         result:^(HLLOfflineWebResultEvent result, NSString *message){
                                                         }];
            }
            if ([HLLOfflineWebPackage getInstance].logBlock) {
                [HLLOfflineWebPackage getInstance].logBlock(
                    HLLOfflineWebLogLevelInfo, @"offwebpack",
                    [NSString stringWithFormat:@"predownload task count:%lu", (unsigned long)[downloadList count]]);
            } else {
                NSLog(@"[!] => offwebConfig missing logBlock. you should set logBlock in offwebConfig init process by "
                      @"call function setInitalParam:... first.");
            }
        }
    }
}
@end
