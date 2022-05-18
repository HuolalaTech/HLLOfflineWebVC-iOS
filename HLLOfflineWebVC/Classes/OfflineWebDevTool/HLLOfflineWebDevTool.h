//
//  HLLOfflineWebVC.m
//  HLLOfflineWebVC
//
//  Created by 货拉拉 on 2021/11/2.
//

#import <UIKit/UIKit.h>

/// Debug模式下，离线包调试工具
@interface HLLOfflineWebDevTool : NSObject

/// 附加到指定的vc对应的视图上展示，通常parentVc为对应的webvc对象
/// @note 通常此方法在parentVc的viewDidLoad中调用，可以保证不影响parentVc的相关系统级view出现消失的事件回调时机
- (void)attachToParentVc:(UIViewController *)parentVc;

/// 设置开发工具对应的当前页的相关数据
/// @param nsurl 当前页面Url
/// @param bisName 当前页面对应的离线包的业务名
/// @note 点击开发调试工具按钮时会用到这里设置的相关数据
- (void)setWebInfo:(NSURL *)nsurl bisName:(NSString *)bisName;

@end
