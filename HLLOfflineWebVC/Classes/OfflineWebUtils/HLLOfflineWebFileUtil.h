//
//  HLLOfflineWebFileUtil.h
//  OfflineWebPackage
//
//  Created by 货拉拉 on 2021/7/20.
//

#import "HLLOfflineWebConst.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 文件操作工具类
@interface HLLOfflineWebFileUtil : NSObject

/// zip文件解压
/// @param src zip文件本地路径
/// @param dst 解压的目的path
/// @param result 结果回调
+ (void)unzipLocalFile:(NSString *)src dst:(NSString *)dst result:(HLLOfflineWebResultBlock)result;

/// 获取指定路径的文件的存储空间大小
/// @param path 对应文件的路径
/// @return 如果path文件不存在则返回-1, 否则返回其存储空间大小，单位为:kb
/// @warning 此方法只能获取单个实体文件的存储空间，不能正确统计一个目录中的总存储空间
+ (CGFloat)getFileSize:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
