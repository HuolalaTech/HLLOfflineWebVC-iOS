//
//  HLLOfflineWebBisNameMatch.h
//
//  Created by 货拉拉 on 2022/1/15.
//

#import <Foundation/Foundation.h>

/// URL和离线包通用关系映射
/// 未了解决开启离线包需要修改URL添加离线包参数繁琐的问题，通过远程配置，给命中规则的H5页面自动添加离线包参数

NS_ASSUME_NONNULL_BEGIN

@interface HLLOfflineWebBisNameMatch : NSObject

/// 处理H5链接，给命中匹配规则的URL添加离线包参数
/// @param string 原始请求地址
/// @param baseConfig 远程配置上的json值
/// @return 处理后的地址，未匹配上则返回原地址
+ (NSString *)filterWebURLString:(NSString *)string baseConfig:(NSDictionary *)baseConfig;

@end

NS_ASSUME_NONNULL_END
