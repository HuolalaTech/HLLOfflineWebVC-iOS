//
//  HLLIconButton.m
//  HLLOfflineWebVC_Example
//
//  Created by 货拉拉 on 2022/5/11.
//  Copyright © 2022 货拉拉. All rights reserved.
//

#import "HLLIconButton.h"
@implementation HLLIconButton
- (instancetype)initWithFrame:(CGRect)frame Icon:(UIImage *)image Text:(NSString *)text {
    self = [super initWithFrame:frame];
    if (self) {
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(24, 16, 16, 16)];
    [imageView setImage:image];
    [self addSubview:imageView];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(64, 16, 1, 16)];
    [label setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.5]];
    [self addSubview:label];

    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(89, 13, 104, 22)];
    [textLabel setText:text];
    [textLabel setTextColor:[UIColor whiteColor]];
    [textLabel setTextAlignment:(NSTextAlignmentLeft)];
    [textLabel setFont:[UIFont systemFontOfSize:15]];
    [self addSubview:textLabel];

    [self setBackgroundColor:[UIColor colorWithRed:37.0 / 255 green:43.0 / 255 blue:71.0 / 255 alpha:1]];
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1;
    self.layer.cornerRadius = 4;
    return self;
}
@end
