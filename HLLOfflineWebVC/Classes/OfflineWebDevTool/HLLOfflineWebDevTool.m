//
//  HLLOfflineWebVC.m
//  HLLOfflineWebVC
//
//  Created by 货拉拉 on 2021/11/2.
//

#import "HLLOfflineWebDevTool.h"
#import "HLLOfflineWebFileMgr.h"
#import <CRToast/CRToast.h>
@interface HLLOfflineWebDevTool ()

@property (nonatomic, weak) UIViewController *parentVC;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesRecognizer;
@property (nonatomic, strong) UIButton *webDevBtn;
@property (nonatomic, strong) NSURL *nsurl;
@property (nonatomic, copy) NSString *bisName;
@end

@implementation HLLOfflineWebDevTool

- (void)attachToParentVc:(UIViewController *)parentVc {
    self.parentVC = parentVc;
    [parentVc.view addSubview:self.webDevBtn];
}

- (UIButton *)webDevBtn {
    if (!_webDevBtn) {
        _webDevBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _webDevBtn.titleLabel.numberOfLines = 0;
        _webDevBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_webDevBtn setTitle:@" 开发者\n  工具" forState:UIControlStateNormal];
        [_webDevBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _webDevBtn.backgroundColor = [UIColor colorWithRed:241.0/255 green:102.0/255 blue:34.0/255 alpha:1];
        _webDevBtn.layer.cornerRadius = 25;
        [_webDevBtn setFrame:CGRectMake(10, 100, 50, 50)];
        //拖拽手势
        self.panGesRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(onPanGesRecognizer:)];
        [_webDevBtn addGestureRecognizer:self.panGesRecognizer];
        [_webDevBtn addTarget:self action:@selector(testBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _webDevBtn;
}

- (void)testBtnClick {
    NSString *displayLabel = @"加载未完成，请稍后";
    NSString *offwebLabel = @"未开启离线包功能";
    if (self.nsurl != nil) {
        if (self.nsurl.isFileURL) {
            displayLabel = @"离线包模式";
        } else {
            displayLabel = @"线上网页模式";
        }
        if (self.bisName) {
            offwebLabel =
                [NSString stringWithFormat:@"离线包版本:%@", [HLLOfflineWebFileMgr getDiskCurVersion:self.bisName]];
        }
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:displayLabel
                                                                             message:offwebLabel
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"清除离线包"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          BOOL ret = [HLLOfflineWebFileMgr deleteDiskCache];
                                                          if (ret) {
                                                              [CRToastManager showNotificationWithMessage:@"清除离线包成功"
                                                                                          completionBlock:^{
                                                                                              NSLog(@"Completed");
                                                                                          }];

                                                          } else {
                                                              [CRToastManager showNotificationWithMessage:@"清除离线包失败"
                                                                                          completionBlock:^{
                                                                                              NSLog(@"Completed");
                                                                                          }];
                                                          }
                                                      }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          NSLog(@"点击取消");
                                                      }]];
    // 由于它是一个控制器 直接modal出来就好了
    [self.parentVC presentViewController:alertController animated:YES completion:nil];
}

- (void)onPanGesRecognizer:(UIPanGestureRecognizer *)ges {
    if (ges.state == UIGestureRecognizerStateChanged || ges.state == UIGestureRecognizerStateEnded) {
        // translationInView：获取到的是手指移动后，在相对坐标中的偏移量
        CGPoint offset = [ges translationInView:self.parentVC.view];
        CGPoint center = CGPointMake(self.webDevBtn.center.x + offset.x, self.webDevBtn.center.y + offset.y);
        [self.webDevBtn setCenter:center];
        [ges setTranslation:CGPointMake(0, 0) inView:self.parentVC.view];
    }
}

- (void)setWebInfo:(NSURL *)nsurl bisName:(NSString *)bisName {
    self.nsurl = nsurl;
    self.bisName = bisName;
}

@end
