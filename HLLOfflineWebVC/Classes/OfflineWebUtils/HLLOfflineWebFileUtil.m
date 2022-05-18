//
//  HLLOfflineWebFileUtil.m
//  OfflineWebPackage
//
//  Created by 货拉拉 on 2021/7/20.
//

#import "HLLOfflineWebFileUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import <SSZipArchive/SSZipArchive.h>

@implementation HLLOfflineWebFileUtil

+ (void)unzipLocalFile:(NSString *)src dst:(NSString *)dst result:(HLLOfflineWebResultBlock)result {
    [SSZipArchive unzipFileAtPath:src
        toDestination:dst
        preserveAttributes:nil
        overwrite:YES
        nestedZipLevel:0
        password:nil
        error:nil
        delegate:nil
        progressHandler:^(NSString *_Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
            //解压进度回调，暂忽略
        }
        completionHandler:^(NSString *_Nonnull path, BOOL succeeded, NSError *_Nullable error) {
            //解压结果回调
            if (succeeded) {
                result(HLLOfflineWebUnzipSuccess, @"unzip success");
            } else {
                result(HLLOfflineWebUnzipError, [error description]);
            }
        }];
}

+ (CGFloat)getFileSize:(NSString *)path {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    CGFloat filesize = -1.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil]; //获取文件的属性
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0 * size / 1024;
    }
    return filesize;
}

@end
