//
//  HLLActionSheet.m
//  HLLOfflineWebVC_Example
//
//  Created by 货拉拉 on 2022/5/11.
//  Copyright © 2022 货拉拉. All rights reserved.
//

#import "HLLActionSheet.h"
#import <Masonry/Masonry.h>

#define GetScreenWidth [[UIScreen mainScreen] bounds].size.width
#define GetScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface HLLActionSheet ()
@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, copy) NSString *contentText;

@end
@implementation HLLActionSheet
- (instancetype)initWithTitle:(NSString *)title Content:(NSString *)content {
    self = [super init];
    if (self) {
        self.titleText = title;
        self.contentText = content;
    }
    return self;
}
- (void)viewDidLoad {
    // UIView 的部分圆角的设定
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, GetScreenHeight - 300, GetScreenWidth, 300)];
    [self.view addSubview:mainView];
    [mainView setBackgroundColor:[UIColor whiteColor]];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:mainView.bounds
                                                   byRoundingCorners:(UIRectCornerTopRight | UIRectCornerTopLeft)
                                                         cornerRadii:CGSizeMake(16, 16)]; //圆角大小
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = mainView.bounds;
    maskLayer.path = maskPath.CGPath;
    mainView.layer.mask = maskLayer;

    UILabel *titleLabel = [[UILabel alloc] init];
    [mainView addSubview:titleLabel];
    [titleLabel setText:self.titleText];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:16]];
    [titleLabel setTextColor:[UIColor blackColor]];
    [titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(mainView).offset(11);
        make.height.mas_equalTo(22);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
    }];

    UILabel *contentLabel = [[UILabel alloc] init];
    [mainView addSubview:contentLabel];
    [contentLabel setText:self.contentText];
    [contentLabel setTextColor:[UIColor blackColor]];
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [contentLabel setFont:[UIFont systemFontOfSize:14]];
    contentLabel.numberOfLines = 0;
    [contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(5);
        make.bottom.mas_equalTo(-50);
        make.left.equalTo(mainView).offset(20);
        make.right.equalTo(mainView).offset(-20);
    }];

    UIButton *iconCloseButton = [[UIButton alloc] initWithFrame:CGRectMake(19.33, 15.33, 13.3, 13.3)];
    [iconCloseButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"resource/close1"
                                                                                               ofType:@"png"]]
                     forState:UIControlStateNormal];
    [mainView addSubview:iconCloseButton];
    [iconCloseButton addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *textcloseButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 13.3, 13.3)];
    [textcloseButton setTitle:@"关闭" forState:UIControlStateNormal];
    [textcloseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    textcloseButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [textcloseButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    textcloseButton.layer.borderWidth = 1;
    textcloseButton.layer.cornerRadius = 8;
    textcloseButton.layer.borderColor =
        [UIColor colorWithRed:216.0 / 255 green:222.0 / 255 blue:235.0 / 255 alpha:1].CGColor;
    [mainView addSubview:textcloseButton];
    [textcloseButton addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [textcloseButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(mainView.mas_bottom).offset(-34);
        make.height.mas_equalTo(48);
        make.left.equalTo(mainView).offset(16);
        make.right.equalTo(mainView).offset(-16);
    }];
}

- (void)closeBtnClick:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
