//
//  OfflineWebFileMgr.m
//  OfflineWebPackage
//
//  Created by 货拉拉 on 2021/8/11.
//

#import "HLLOfflineWebFileMgr.h"
#import "HLLOfflineWebFileUtil.h"
#import "HLLOfflineWebPackage+callbacks.h"

/// log方法宏定义
NS_INLINE void HLLOfflineWebFileMgr_offlineWebLog(HLLOfflineWebLogLevel level, NSString *keyword, NSString *message) {
    [HLLOfflineWebPackage getInstance].logBlock(level, keyword, message);
};

@implementation HLLOfflineWebFileMgr

+ (NSString *)getOfflineWebStorePath:(NSString *)bisName {
    NSString *documentPath =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [documentPath stringByAppendingString:[NSString stringWithFormat:@"/offlineWeb/%@", bisName]];
    return path;
}

+ (void)doZiptoNewFolder:(NSString *)bisName Zip:(NSString *)zipPath Result:(HLLOfflineWebResultBlock)resultBlock {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    //存储zip
    NSString *storePath = [self getOfflineWebStorePath:bisName];
    NSString *newFolder = [storePath stringByAppendingString:@"/new"];
    NSString *tempFolder = [storePath stringByAppendingString:@"/temp"];
    NSString *curFolder = [storePath stringByAppendingString:@"/cur"];

    if (![fileManager fileExistsAtPath:storePath]) {
        //解决该目录未创建，解压时报找不到指定目录错误的问题
        [fileManager createDirectoryAtPath:storePath withIntermediateDirectories:YES attributes:nil error:nil];
        // create folder
        HLLOfflineWebFileMgr_offlineWebLog(HLLOfflineWebLogLevelWarning, bisName, @"create storePath");
    }
    if ([fileManager fileExistsAtPath:tempFolder]) {
        //可能存在之前解压一半的情况
        [fileManager removeItemAtPath:tempFolder error:nil]; // del temp
        HLLOfflineWebFileMgr_offlineWebLog(HLLOfflineWebLogLevelWarning, bisName, @"del temp folder");
    }

    [HLLOfflineWebFileUtil
        unzipLocalFile:zipPath
                   dst:tempFolder
                result:^(HLLOfflineWebResultEvent result, NSString *message) {
                    if (result == HLLOfflineWebUnzipSuccess) {
                        if (![fileManager fileExistsAtPath:curFolder]) {
                            // curFolder不存在
                            [fileManager moveItemAtPath:tempFolder toPath:curFolder error:nil]; // temp->cur
                            HLLOfflineWebFileMgr_offlineWebLog(HLLOfflineWebLogLevelInfo, bisName, @"tmp->cur");
                        } else {
                            [fileManager removeItemAtPath:newFolder error:nil];                 // del new
                            [fileManager moveItemAtPath:tempFolder toPath:newFolder error:nil]; // temp->new
                            HLLOfflineWebFileMgr_offlineWebLog(HLLOfflineWebLogLevelInfo, bisName, @"temp->new");
                        }
                    }

                    resultBlock(result, message);
                }];
}

+ (void)deleteOldFolder:(NSString *)bisName {
    NSString *storePath = [self getOfflineWebStorePath:bisName];
    NSString *oldFolder = [storePath stringByAppendingString:@"/old"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:oldFolder]) {
        [fileManager removeItemAtPath:oldFolder error:nil]; //重命名之前删除old
        HLLOfflineWebFileMgr_offlineWebLog(HLLOfflineWebLogLevelWarning, bisName, @"del old folder");
    }
}

+ (BOOL)doNewFolder2CurFolder:(NSString *)bisName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *storePath = [self getOfflineWebStorePath:bisName];
    NSString *oldFolder = [storePath stringByAppendingString:@"/old"];
    NSString *curFolder = [storePath stringByAppendingString:@"/cur"];
    NSString *newFolder = [storePath stringByAppendingString:@"/new"];

    if (![fileManager fileExistsAtPath:newFolder]) {
        //新目录没有直接返回
        HLLOfflineWebFileMgr_offlineWebLog(HLLOfflineWebLogLevelWarning, bisName, @"no new folder");
        return NO;
    }

    if (![fileManager fileExistsAtPath:curFolder]) {
        //当前目录不存在，直接重命名
        NSError *renameError = nil;
        [fileManager moveItemAtPath:newFolder toPath:curFolder error:&renameError];
        if (renameError) {
            //重命名失败
            HLLOfflineWebFileMgr_offlineWebLog(HLLOfflineWebLogLevelError, bisName, @"new ->cur folder fail");
            return NO;
        }
    } else {
        NSError *renameError = nil;
        [self deleteOldFolder:bisName];
        [fileManager moveItemAtPath:curFolder toPath:oldFolder error:&renameError]; // cur ->old
        if (renameError) {
            //文件夹占用中，下次更新
            HLLOfflineWebFileMgr_offlineWebLog(HLLOfflineWebLogLevelError, bisName, @"cur ->old folder fail");
            return NO;
        } else {
            NSError *renameError2 = nil;
            [fileManager moveItemAtPath:newFolder toPath:curFolder error:&renameError2]; // new->cur
            if (renameError2) {
                HLLOfflineWebFileMgr_offlineWebLog(HLLOfflineWebLogLevelError, bisName, @"new->cur folder fail");
                return NO;
            }
        }
    }

    return YES;
}

+ (BOOL)deleteDiskCache {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentPath =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [documentPath stringByAppendingString:[NSString stringWithFormat:@"/offlineWeb/"]];
    NSError *removeError = nil;
    [fileManager removeItemAtPath:path error:&removeError];
    if (!removeError) {
        return YES;
    } else {
        return NO;
    }
}

//删除某个业务的离线包
+ (BOOL)deleteDiskCache:(NSString *)bisName {
    NSString *path = [self getOfflineWebStorePath:bisName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    [fileManager removeItemAtPath:path error:&error];
    if (!error) {
        HLLOfflineWebFileMgr_offlineWebLog(HLLOfflineWebLogLevelWarning, bisName, @"del cache success");
        return YES;
    } else {
        HLLOfflineWebFileMgr_offlineWebLog(HLLOfflineWebLogLevelError, bisName, @"del cache fail");
        return NO;
    }
}

+ (NSString *)getDiskCurVersion:(NSString *)bisName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *storePath = [self getOfflineWebStorePath:bisName];
    NSString *curVerPath = [storePath stringByAppendingString:@"/cur/.offweb.json"];
    if ([fileManager fileExistsAtPath:curVerPath]) {
        NSData *jsonData = [[NSData alloc] initWithContentsOfFile:curVerPath];
        if (jsonData == nil) {
            return @"0";
        }

        NSError *error = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
        if (!jsonData || error) {
            HLLOfflineWebFileMgr_offlineWebLog(
                HLLOfflineWebLogLevelError, bisName,
                [NSString stringWithFormat:@"getDiskCurVersion,json decode error.  %@", error.description]);
            return @"0";
        } else {
            return dict[@"ver"];
        }
    }

    return @"0";
}

+ (NSString *)getDiskNewVersion:(NSString *)bisName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *storePath = [self getOfflineWebStorePath:bisName];
    NSString *curVerPath = [storePath stringByAppendingString:@"/new/.offweb.json"];
    if ([fileManager fileExistsAtPath:curVerPath]) {
        NSData *jsonData = [[NSData alloc] initWithContentsOfFile:curVerPath];
        if (jsonData == nil) {
            return @"0";
        }

        NSError *error = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
        if (!jsonData || error) {
            // DLog(@"JSON解码失败");
            HLLOfflineWebFileMgr_offlineWebLog(
                HLLOfflineWebLogLevelError, bisName,
                [NSString stringWithFormat:@"getDiskNewVersion,json decode error.  %@", error.description]);
            return @"0";
        } else {
            return dict[@"ver"];
        }
    }

    return @"0";
}

+ (NSString *)getPath:(NSString *)bisName {
    NSString *storePath = [self getOfflineWebStorePath:bisName];
    NSString *curFolderPath = [storePath stringByAppendingString:@"/cur/index.html"];
    return curFolderPath;
}

@end
