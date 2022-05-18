//
//  HLLOfflineWebPackage+callbacks.h
//  HLLOfflineWebVC
//
//  Created by 货拉拉 on 2022/3/11.
//

#import "HLLOfflineWebConst.h"
#import "HLLOfflineWebPackage.h"

NS_ASSUME_NONNULL_BEGIN

/// 内部使用的一些外部赋值的block回调
@interface HLLOfflineWebPackage ()

@property (nonatomic, copy) HLLOfflineWebLogBlock logBlock;
@property (nonatomic, copy) HLLOfflineWebReportBlock reportBlock;
@property (nonatomic, copy) HLLOfflineWebMonitorBlock monitorBlock;

@end

NS_ASSUME_NONNULL_END
