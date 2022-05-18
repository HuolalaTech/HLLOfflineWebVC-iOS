//
//  HLLViewController.m
//  HLLOfflineWebVC
//
//  Created by 货拉拉 on 11/02/2021.
//  Copyright (c) 2021 货拉拉. All rights reserved.
//
#import "HLLActionSheet.h"
#import "HLLBisnessWebVC.h"
#import "HLLIconButton.h"
#import "HLLOfflineWebFileMgr.h"
#import "HLLOfflineWebPackage.h"
#import "HLLViewController.h"
#import "LocalServerTestController.h"
#import <HLLOfflineWebVC/HLLOfflineWebPackageKit.h>
#import <Masonry/Masonry.h>
//默认开启离线包，并且预拉取测试离线包
#define DefaultWebPackageConfig                                                                                        \
    ({                                                                                                                 \
        NSMutableDictionary *dic = [HLLOfflineWebConfig defaultOffWebConfigDic].mutableCopy;                           \
        dic[kHLLOfflineWebConfigKey_predownloadList] = @[ @"act3-offline-package-test" ];                              \
        dic[kHLLOfflineWebConfigKey_switch] = @(1);                                                                    \
        dic;                                                                                                           \
    })

#define GetScreenWidth [[UIScreen mainScreen] bounds].size.width
#define GetScreenHeight [[UIScreen mainScreen] bounds].size.height

#define TestUrl @"https://www.baidu.com/?offweb=act3-offline-package-test"

@interface HLLViewController ()
@property (nonatomic, strong) HLLIconButton *predownloadBtn;
@property (nonatomic, strong) HLLIconButton *openWebviewBtn;
@property (nonatomic, strong) HLLIconButton *testgetFileURLBtn;
@property (nonatomic, strong) HLLIconButton *testgetOffWebBisNameBtn;
@end

@implementation HLLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    LocalServerTestController *localServerVC = [[LocalServerTestController alloc] init];
    [self.view addSubview:localServerVC.view];
    [self addChildViewController:localServerVC];
    [self initUI];
    [self initOfflineWeb];
    [self preDownloadOfflineWeb];
}
- (void)initOfflineWeb {
    NSDictionary *offwebConfigDict = DefaultWebPackageConfig;
    //初始化离线包block
    [HLLOfflineWebConfig setInitalParam:offwebConfigDict
        logBlock:^(HLLOfflineWebLogLevel level, NSString *keyword, NSString *message) {
            if (keyword == nil || message == nil) {
                NSLog(@"offwebpack,para is nil");
                return;
            }
            switch (level) {
                case HLLOfflineWebLogLevelError:
                case HLLOfflineWebLogLevelWarning:
                case HLLOfflineWebLogLevelInfo:
                case HLLOfflineWebLogLevelDebug:
                    NSLog(@"offwebpack:%d:%@:%@", (int)level, keyword, message);
                    break;
                default:
                    break;
            }
        }
        reportBlock:^(NSString *event, NSDictionary *dict) {
            if (event == nil || dict == nil) {
                NSLog(@"offwebpack,parse is nil");
                return;
            }
            NSLog(@"data report:%@,%@", event, dict);
        }
        monitorBlock:^(HLLOfflineWebMonitorType type, NSString *key, CGFloat value, NSDictionary *lables) {
            if (type == HLLOfflineWebMonitorTypeCounter) {
                NSLog(@"use your monitor sdk ");
            } else if (type == HLLOfflineWebMonitorTypeSummary) {
                NSLog(@"use your monitor sdk ");
            }
        }
        env:@"prd"
        appversion:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
}

- (void)preDownloadOfflineWeb {
    NSDictionary *offwebConfigDict = DefaultWebPackageConfig;
    [HLLOfflineWebConfig predownloadOffWebPackage:offwebConfigDict];
}

- (void)initUI {
    [self.view setBackgroundColor:[UIColor colorWithRed:15.0 / 255 green:18.0 / 255 blue:41.0 / 255 alpha:0.75]];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GetScreenWidth, GetScreenHeight)];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"resource/background" ofType:@"png"];
    [imageView setImage:[UIImage imageWithContentsOfFile:path]];
    [self.view addSubview:imageView];

    UIImageView *logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
    [logoImage setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"resource/logo"
                                                                                         ofType:@"png"]]];
    [self.view addSubview:logoImage];
    [logoImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(125 - 60);
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(64.0);
        make.height.mas_equalTo(64.0);
    }];

    UIImageView *nameImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
    [nameImage setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"resource/name"
                                                                                         ofType:@"png"]]];
    [self.view addSubview:nameImage];
    [nameImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(logoImage.mas_bottom).offset(10);
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(99.0);
        make.height.mas_equalTo(36.0);
    }];

    UILabel *titleText = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, GetScreenWidth - 20, 30)];
    [titleText setText:@"离线包DEMO"];
    [titleText setTextAlignment:NSTextAlignmentCenter];
    [titleText setTextColor:[UIColor whiteColor]];
    [titleText setFont:[UIFont systemFontOfSize:18]];
    [self.view addSubview:titleText];
    [titleText mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(nameImage.mas_bottom).offset(10);
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(150.0);
        make.height.mas_equalTo(30.0);
    }];

    //第一行按钮
    self.predownloadBtn = [[HLLIconButton alloc]
        initWithFrame:CGRectMake(20, 500, 270, 48)
                 Icon:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"resource/up"
                                                                                       ofType:@"png"]]
                 Text:@"检查更新"];
    [self.view addSubview:self.predownloadBtn];
    [self.predownloadBtn addTarget:self action:@selector(predownload:) forControlEvents:UIControlEventTouchUpInside];
    [self.predownloadBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-57 + 30);
        make.height.mas_equalTo(48);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
    }];

    self.openWebviewBtn = [[HLLIconButton alloc]
        initWithFrame:CGRectMake(20, 500, 270, 48)
                 Icon:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"resource/split"
                                                                                       ofType:@"png"]]
                 Text:@"打开webview"];
    [self.openWebviewBtn addTarget:self action:@selector(openWebview:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.openWebviewBtn];
    [self.openWebviewBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.predownloadBtn.mas_top).offset(-10);
        make.height.mas_equalTo(48);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
    }];

    self.testgetFileURLBtn = [[HLLIconButton alloc]
        initWithFrame:CGRectMake(20, 500, 270, 48)
                 Icon:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"resource/navigation"
                                                                                       ofType:@"png"]]
                 Text:@"离线包路径"];
    [self.view addSubview:self.testgetFileURLBtn];
    [self.testgetFileURLBtn addTarget:self
                               action:@selector(testgetFileURL:)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.testgetFileURLBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.openWebviewBtn.mas_top).offset(-10);
        make.height.mas_equalTo(48);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
    }];

    self.testgetOffWebBisNameBtn = [[HLLIconButton alloc]
        initWithFrame:CGRectMake(20, 500, 270, 48)
                 Icon:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"resource/user"
                                                                                       ofType:@"png"]]
                 Text:@"离线包id"];
    [self.view addSubview:self.testgetOffWebBisNameBtn];
    [self.testgetOffWebBisNameBtn addTarget:self
                                     action:@selector(testgetOffWebBisName:)
                           forControlEvents:UIControlEventTouchUpInside];
    [self.testgetOffWebBisNameBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.testgetFileURLBtn.mas_top).offset(-10);
        make.height.mas_equalTo(48);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
    }];
}
- (void)predownload:(UIButton *)button {
    NSLog(@"%@", button);
    NSString *bisName = [[HLLOfflineWebPackage getInstance] getOffWebBisName:TestUrl];
    [[HLLOfflineWebPackage getInstance]
        checkUpdate:bisName
             result:^(HLLOfflineWebResultEvent result, NSString *msg) {
                 [self displayResult:@"查询结果"
                             Content:[NSString stringWithFormat:@"result:%ld  msg:%@", (long)result, msg]];
             }];
}

- (void)openWebview:(UIButton *)button {
    HLLBisnessWebVC *vc = [[HLLBisnessWebVC alloc] initWithUrl:TestUrl];
    vc.title = @"测试H5页面";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];

    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)testgetFileURL:(UIButton *)button {
    NSURL *filePath = [[HLLOfflineWebPackage getInstance] getFileURL:[NSURL URLWithString:TestUrl]];
    [self displayResult:@"离线包路径" Content:filePath.absoluteString];
}
- (void)testgetOffWebBisName:(UIButton *)button {
    NSString *bisName = [[HLLOfflineWebPackage getInstance] getOffWebBisName:TestUrl];
    [self displayResult:@"离线包id" Content:bisName];
}

- (void)displayResult:(NSString *)title Content:(NSString *)content {
    HLLActionSheet *actionSheet = [[HLLActionSheet alloc] initWithTitle:title Content:content];
    actionSheet.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:actionSheet animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
