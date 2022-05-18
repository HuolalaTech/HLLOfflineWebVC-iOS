//
//  HLLIconButton.h
//  HLLOfflineWebVC_Example
//
//  Created by 货拉拉 on 2022/5/11.
//  Copyright © 2022 货拉拉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
///自定义按钮
@interface HLLIconButton : UIButton
- (instancetype)initWithFrame:(CGRect)frame Icon:(UIImage *)image Text:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
