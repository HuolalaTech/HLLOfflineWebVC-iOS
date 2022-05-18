//
//  HLLOfflineWebBisNameMatch.m
//  123456
//
//  Created by 货拉拉 on 2022/1/15.
//

#import "HLLOfflineWebBisNameMatch.h"

@interface HLLWebCacheItem : NSObject

@property (nonatomic, copy) NSArray *hosts;           // 缓存域名
@property (nonatomic, copy) NSArray *paths;           // 缓存路径
@property (nonatomic, copy) NSArray *fragmentprefixs; // 缓存页面路由名
@property (nonatomic, copy) NSString *offweb;         // 缓存类型

@end

@implementation HLLWebCacheItem

+ (instancetype)createWebCacheItemWithConf:(NSDictionary *)config {
    HLLWebCacheItem *item = [[HLLWebCacheItem alloc] init];
    item.hosts = [self arrayResult:config[@"host"]];
    item.paths = [self arrayResult:config[@"path"]];
    item.fragmentprefixs = [self arrayResult:config[@"fragmentprefix"]];
    item.offweb = [NSString stringWithFormat:@"%@", config[@"offweb"]];
    return item;
}

+ (NSArray *)arrayResult:(id)result {
    if (result && [result isKindOfClass:[NSArray class]]) {
        return result;
    }
    return @[];
}

@end

@implementation HLLOfflineWebBisNameMatch

+ (NSString *)filterWebURLString:(NSString *)string baseConfig:(NSDictionary *)baseConfig {
    if (baseConfig && [baseConfig isKindOfClass:[NSDictionary class]]) {
        NSString *offlineUrl = @"";
        if (string && [string isKindOfClass:[NSString class]] && string.length > 0) {
            NSURL *url = [NSURL URLWithString:string];
            if (url) {
                if ([string containsString:@"/#/"]) {
                    // 1.采用SPA单页面路由
                    offlineUrl = [self parserSPAUrl:url baseConfig:baseConfig];
                    // 2.兼容线上已有的地址
                } else if ([string containsString:@"#/"] && ![string containsString:@"/#/"]) {
                    offlineUrl = [self parserSPAHandledUrl:url baseConfig:baseConfig];
                } else {
                    // 3.一般H5页面地址
                    offlineUrl = [self parserNormalUrl:url baseConfig:baseConfig];
                }
            }
        }
        return offlineUrl;
    }
    return string;
}

// mock数据测试
+ (NSDictionary *)requestMockConfig {
    return @{
        @"rules" : @[
            @{
                @"host" : @[ @"test1.huolala.cn", @"www.baidu.com" ],
                @"path" : @[ @"/uapp", @"/abc/123", @"/uapp/cd-index.html", @"/uapp/*/cd-index-abc" ],
                @"fragmentprefix" : @[ @"/cd-index", @"12" ],
                @"offweb" : @"uappweb-offline_update"
            },
            @{
                @"host" : @[ @"test2.huolala.cn", @"www.baidu1.com" ],
                @"path" : @[ @"/uapp", @"/abc/123" ],
                @"fragment" : @[ @"/cd-index" ],
                @"offweb" : @"uappweb-offline"
            }
        ]
    };
}

+ (NSArray *)requestCacheConf:(NSDictionary *)baseConfig {
    NSDictionary *conf = baseConfig;
    NSMutableArray *tempArr = [NSMutableArray array];
    NSArray *rules = conf[@"rules"];
    if (rules && [rules isKindOfClass:[NSArray class]] && rules.count > 0) {
        for (NSInteger i = 0; i < rules.count; i++) {
            NSDictionary *dict = rules[i];
            if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                // host path offweb 不能为空
                NSArray *host = dict[@"host"];
                NSArray *path = dict[@"path"];
                NSString *offweb = dict[@"offweb"];
                if ([self arrayValid:host] && [self arrayValid:path] && [self stringValid:offweb]) {
                    HLLWebCacheItem *item = [HLLWebCacheItem createWebCacheItemWithConf:dict];
                    [tempArr addObject:item];
                }
            }
        }
    }
    return tempArr;
}

+ (BOOL)arrayValid:(NSArray *)array {
    if (array && [array isKindOfClass:[NSArray class]] && array.count > 0) {
        return YES;
    }
    return NO;
}

+ (BOOL)stringValid:(NSString *)string {
    if (string && [string isKindOfClass:[NSString class]] && string.length > 0) {
        return YES;
    }
    return NO;
}

+ (NSString *)parserSPAUrl:(NSURL *)URL baseConfig:(NSDictionary *)baseConfig {
    NSString *offweb = [self checkNeedCacheURL:URL baseConfig:baseConfig];
    if (offweb && [offweb isKindOfClass:[NSString class]] && offweb.length > 0) {
        NSString *query = URL.query;
        if (query && [query containsString:@"="]) {
            query = [self handleHasQuerySPAUrl:URL offweb:offweb];
            return [NSString stringWithFormat:@"%@://%@%@?%@#%@", URL.scheme, URL.host, URL.path, query, URL.fragment];
        }
        return
            [NSString stringWithFormat:@"%@://%@%@?offweb=%@#%@", URL.scheme, URL.host, URL.path, offweb, URL.fragment];
    } else {
        return URL.absoluteString;
    }
}

+ (NSString *)handleHasQuerySPAUrl:(NSURL *)URL offweb:(NSString *)offweb {
    NSString *query = URL.query;
    if (query && [query containsString:@"offweb="]) {
        // H5链接自带offweb参数，覆盖掉
        NSArray *arr = [query componentsSeparatedByString:@"&"];
        NSMutableString *muStr = [NSMutableString string];
        for (int i = 0; i < arr.count; i++) {
            NSString *val = arr[i];
            if ([val containsString:@"offweb="]) {
                [muStr appendString:[NSString stringWithFormat:@"offweb=%@", offweb]];
            } else {
                [muStr appendString:val];
            }
            if (i != arr.count - 1) {
                [muStr appendString:@"&"];
            }
        }
        return muStr;
    }
    return [NSString stringWithFormat:@"%@&offweb=%@", query, offweb];
}

+ (NSString *)checkNeedCacheURL:(NSURL *)URL baseConfig:(NSDictionary *)baseConfig {
    NSString *final_offweb = @"";
    NSArray *items = [self requestCacheConf:baseConfig];
    for (NSInteger i = 0; i < items.count; i++) {
        HLLWebCacheItem *item = items[i];
        NSArray *hosts = item.hosts;
        NSArray *paths = item.paths;
        NSArray *fragmentprefixs = item.fragmentprefixs;
        NSString *offweb = item.offweb;
        if ([self checkHost:URL.host config:hosts] && [self checkPath:URL.path config:paths] &&
            [self checkFragmentprefix:URL.fragment config:fragmentprefixs]) {
            final_offweb = offweb;
        }
    }
    return final_offweb;
}

+ (BOOL)checkHost:(NSString *)host config:(NSArray *)hosts {
    BOOL result = NO;
    for (NSInteger j = 0; j < hosts.count; j++) {
        NSString *indexHost = [NSString stringWithFormat:@"%@", hosts[j]];
        if ([host isEqualToString:indexHost]) {
            result = YES;
            break;
        }
    }
    return result;
}

+ (BOOL)checkPath:(NSString *)path config:(NSArray *)paths {
    BOOL result = NO;
    for (NSInteger j = 0; j < paths.count; j++) {
        NSString *indexPath = [NSString stringWithFormat:@"%@", paths[j]];
        NSArray *pathSplitArray = [path componentsSeparatedByString:@"/"];
        NSArray *indexPathSplitArray = [indexPath componentsSeparatedByString:@"/"];
        BOOL compareRes = [self compareSplitPath:pathSplitArray indexPathSplit:indexPathSplitArray];
        if (compareRes) {
            result = YES;
            break;
        }
    }
    return result;
}

+ (BOOL)compareSplitPath:(NSArray *)pathSplitArray indexPathSplit:(NSArray *)indexPathSplitArray {
    BOOL result = YES;
    if (pathSplitArray.count != indexPathSplitArray.count) {
        result = NO;
    } else {
        for (NSInteger i = 0; i < pathSplitArray.count; i++) {
            NSString *path = [NSString stringWithFormat:@"%@", pathSplitArray[i]];
            NSString *indexPath = [NSString stringWithFormat:@"%@", indexPathSplitArray[i]];
            if ([indexPath isEqualToString:@"*"]) {
                continue;
            }
            if (![path isEqualToString:indexPath]) {
                result = NO;
                break;
            }
        }
    }
    return result;
}

+ (BOOL)checkFragmentprefix:(NSString *)fragmentprefix config:(NSArray *)fragmentprefixs {
    fragmentprefix = [NSString stringWithFormat:@"%@", fragmentprefix];
    if (fragmentprefixs.count == 0) {
        return NO;
    }
    fragmentprefix = [self parserFragmentprefix:fragmentprefix];
    BOOL result = NO;
    if (fragmentprefix && [fragmentprefix isKindOfClass:[NSString class]]) {
        for (NSInteger j = 0; j < fragmentprefixs.count; j++) {
            NSString *indexFragmentprefix = [NSString stringWithFormat:@"%@", fragmentprefixs[j]];
            if ([fragmentprefix isEqualToString:indexFragmentprefix]) {
                result = YES;
                break;
            }
        }
    }
    return result;
}

+ (NSString *)parserFragmentprefix:(NSString *)fragmentprefix {
    NSInteger index = 0;
    BOOL charFlag = NO;
    for (NSInteger i = 0; i < [fragmentprefix length]; i++) {
        NSString *cha = [fragmentprefix substringWithRange:NSMakeRange(i, 1)];
        if ([cha isEqualToString:@"?"]) {
            charFlag = YES;
            index = i;
            break;
        }
    }
    if (charFlag) {
        return [fragmentprefix substringToIndex:index];
    }
    return fragmentprefix;
}

+ (NSString *)parserSPAHandledUrl:(NSURL *)URL baseConfig:(NSDictionary *)baseConfig {
    // 3.带有#/,则覆盖线上offweb字段
    return [self parserSPAUrl:URL baseConfig:baseConfig];
}

+ (NSString *)parserNormalUrl:(NSURL *)URL baseConfig:(NSDictionary *)baseConfig {
    // 页面不带有#，如果H5参数有offweb字段则匹配上后直接覆盖掉
    NSString *offweb = [self checkNeedCacheNoFragmentURL:URL baseConfig:baseConfig];
    if (offweb && [offweb isKindOfClass:[NSString class]] && offweb.length > 0) {
        return [self coverURLQueryWithOffweb:offweb URL:URL];
    } else {
        return URL.absoluteString;
    }
}

+ (NSString *)coverURLQueryWithOffweb:(NSString *)offweb URL:(NSURL *)URL {
    NSString *query = URL.query;
    if (query && [query containsString:@"offweb="]) {
        // H5链接自带offweb参数，覆盖掉
        NSArray *arr = [query componentsSeparatedByString:@"&"];
        NSMutableString *muStr = [NSMutableString string];
        for (int i = 0; i < arr.count; i++) {
            NSString *val = arr[i];
            if ([val containsString:@"offweb="]) {
                [muStr appendString:[NSString stringWithFormat:@"offweb=%@", offweb]];
            } else {
                [muStr appendString:val];
            }
            if (i != arr.count - 1) {
                [muStr appendString:@"&"];
            }
        }
        return [NSString stringWithFormat:@"%@://%@%@?%@", URL.scheme, URL.host, URL.path, muStr];
    } else {
        // H5链接不带offweb参数，直接拼接
        if ([URL.absoluteString containsString:@"?"]) {
            if (URL.query && [URL.query containsString:@"="]) {
                return [NSString stringWithFormat:@"%@&offweb=%@", URL.absoluteString, offweb];
            } else {
                return [NSString stringWithFormat:@"%@offweb=%@", URL.absoluteString, offweb];
            }
        } else {
            return [NSString stringWithFormat:@"%@?offweb=%@", URL.absoluteString, offweb];
        }
    }
}

+ (NSString *)checkNeedCacheNoFragmentURL:(NSURL *)URL baseConfig:(NSDictionary *)baseConfig {
    NSString *final_offweb = @"";
    NSArray *items = [self requestCacheConf:baseConfig];
    for (NSInteger i = 0; i < items.count; i++) {
        HLLWebCacheItem *item = items[i];
        NSArray *hosts = item.hosts;
        NSArray *paths = item.paths;
        NSString *offweb = item.offweb;
        if ([self checkHost:URL.host config:hosts] && [self checkPath:URL.path config:paths] &&
            [self checkFragmentprefix:@"" config:item.fragmentprefixs]) {
            final_offweb = offweb;
        }
    }
    return final_offweb;
}

@end
