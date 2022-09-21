<img src=Image/title.png width=100% height=100% />

[![license](https://img.shields.io/hexpm/l/plug.svg)](https://www.apache.org/licenses/LICENSE-2.0)
![Pod Version](https://img.shields.io/badge/pod-v1.0.0-green.svg)
![Pod Version](https://img.shields.io/badge/pod-v1.0.0-green.svg)
![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)
![Language](https://img.shields.io/badge/language-ObjectC-green.svg)
[![wiki](https://img.shields.io/badge/Wiki-open-brightgreen.svg)](https://juejin.cn/post/7103348563479887885)

---
## 介绍

   &emsp;&emsp;HLLOfflineWebVC是货拉拉自研的轻量级高性能H5离线包sdk，可以显著的提升H5页面加载速度，iOS端基于[WKWebView](https://developer.apple.com/documentation/webkit/wkwebview/)实现。
主要原理为：提前缓存html、js、css、图片等资源文件到静态到本地，当H5页面请求资源时，尽量从本地获取数据，减少网络请求。更新原理细节参考文章[《货拉拉H5离线包原理与实践》](https://juejin.cn/post/7103348563479887885)。
## 比较
 | |未使用离线包 |   使用离线包
|--|:-------------------------:|:-------------------------:
| 耗时|2s |   1s
|视频|<img src=Image/1.gif  />  | <img src=Image/2.gif  />


## 特点
-  安全可靠：无hook，无私有API，具有三重降级策略，保证可靠性
-  容易维护：三层架构模式和模块化设计
-  功能完备：功能可配置，数据埋点，开发者工具等功能一应俱全
## 依赖
- iOS 9.0 或更高版本
- Xcode 11.0 或更高版本
- CocoaPods 1.11.2 或更高版本
## 指引
1) 下载源码到本地。

2) 进入”Example“工程目录，输入命令“pod install”安装第三方依赖库。

3) 使用Xcode打开工程“HLLOfflineWebVC.xcworkspace”，然后直接编译运行。

开源代码中使用GCDWebServer在本地搭建了离线包依赖的查询和下载接口，故可以直接本地体验示例工程，界面截图如下：

<img src=Image/1.jpg width=30% height=30% /><img src=Image/2.png width=30% height=30% /> <img src=Image/3.png width=30% height=30% />

## 问题交流
- 如果你发现了bug或者有其他功能诉求，欢迎提issue。
- 如果想贡献代码，可以直接发起MR。
## 主要模块
- OfflineWebPackage

  离线包管理模块，核心模块，包含离线包查询、下载、缓存管理、数据上报功能。
- OfflineWebDevTool

  开发者debug调试工具。方便开发和测试阶段查看和清除离线包。
- OfflineWebBisNameMatch
   
  通过配置实现离线包URL和离线包ID自动匹配。
- OfflineWebUtils

  内部模块使用的辅助功能工具类。

## 使用
&emsp;&emsp;如果要在实际项目中使用，需要采取如下步骤：
### 离线包服务搭建
- 实现查询接口

  https://www.huolala.cn/queryOffline?clientType=iOS&clientVer=1.0.0&offlineZipVer=1.0.0&bisName=xxx

  请求参数接口参数说明：

| 参数名           | 参数含义                      | 备注                                |
|------------------|-------------------------------|-------------------------------------|
| os               | 终端类型                      | iOS，Android                        |
| clientVersion    | 客户端版本                    |  例如：1.0.0                                   |
| bisName          | 业务名，每个页面的离线包独立     | 例如：act3-offline-package-test                 |
| offlineZipVer    | 本地离线包版本                | 自定义参数，0表示本地无             |


 &emsp;&emsp;查询结果返回结果为json，参数说明：

| 参数名       | 参数含义    | 备注                                                                                       |
|--------------|-------------|--------------------------------------------------------------------------------------------|
| bisName      | 业务名      | 例如：act3-offline-package-test                                                                                           |
| result       | 结果        | -1 禁用离线包  0 无更新   1  有新离线包   |
| url          | 离线包（zip压缩包）下载地址   | 没有时为空字符串                                                                           |
| refreshMode  | 刷新模式    | 0 下次刷新（默认）   1  马上强制刷新（极端情况下使用）                                                          |
| version      | 离线包版本  | 例如：25609-j56gfa                              |

- 接口跨域处理

H5离线包加载的路径为文件路径为，发起cgi请求时，origin为null，需要网关或者后端添加跨域支持。

### H5端改造
- 使用相对路径。引用的本地js、css等文件路径需要改成相对路径。
- cookie、localstorage等存储跨域支持。
- 加入版本文件。离线包资源包大包时加入版本描述文件".offweb.json",格式为：
{ "bisName": "xxx", "ver": "xxx" }

## 客户端接入

### 完整接入
&emsp;&emsp;安装离线包所有功能模块，包括自定义的Webview容器全部接入当前工程。
1) 安装离线包SDK

    通过CocoaPods命令安装：pod 'HLLOfflineWebVC'
2) 离线包初始化
 
   参考代码如下：
```
- (void)initOfflineWeb {
    NSDictionary *offwebConfigDict = DefaultWebPackageConfig;
    [HLLOfflineWebConfig setInitalParam:offwebConfigDict
        logBlock:^(HLLOfflineWebLogLevel level, NSString *keyword, NSString *message) {
            NSLog (@"use your log SDK :%d:%@:%@", (int) level, keyword, message);     
        }
        reportBlock:^(NSString *event, NSDictionary *dict) {
            NSLog(@"data report:%@,%@", event, dict);
        }
        monitorBlock:^(HLLOfflineWebMonitorType type, NSString *key, CGFloat value, NSDictionary *lables) {
            NSLog(@"use your monitor sdk ");
            
        }
        env:@"prd"
        appversion:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
}
```

   &emsp;&emsp;logBlock，reportBlock，monitorBlock 为具体的日志、埋点、实时监控SDK实现。

3) 通过参数字典配置功能

   参数offwebConfigDict 为json转化成的字典，用于配置离线包的降级、自动拼接离线包参数配置等功能：
```
{
	"switch": 1,
	"predownloadlist": ["uappweb-offline"],
	"disablelist": [],
	"rules": [{
		  "host": ["test1.xxx.com", "test2.xxx.com"],
		  "path": ["/uapp"],
		  "offweb": "uappweb"
		}
	]
}
```
| 参数名       | 参数含义     |      是否必填                                                                              |
|--------------|-------------|--------------------------------------------------------------------------------------------|
| switch      | 1 开启离线包功能，0 关闭     | 必填                                                                                           |
| predownloadlist       | 预下载离线包列表      | 选填  |
| disablelist          | 需要禁用离线包功能到页面 | 选填                                                                           |
| rules  | H5页面和离线包参数映射规则   | 选填  
           

4) webview容器适配。
参考开源代码中的代码，Webview容器需实现如下接口
```
- (BOOL)webview:(WKWebView *)webview shouldStartLoadWithRequest:(NSURLRequest *)request {
        return YES;
}

```
   &emsp;&emsp;然后将HLLOfflineWebVC的父类修改为业务中的具体webview容器，同时头文件中声明WKWebview公共接口 <WKUIDelegate,WKNavigationDelegate>

### 仅安装核心模块
   &emsp;&emsp; 只安装离线包核心模块，不包含Webview容器，Cocoapods命令：pod 'HLLOfflineWebVC/OfflineWebPackage'
 主要接口如下：

1) 离线包更新检查接口
```
/// @param bisName 离线包业务名
/// @param resultBlock 结果回调

- (void)checkUpdate:(NSString *)bisName result:(HLLOfflineWebResultBlock)resultBlock;
```
2)  获取当前url对应的本地离线包中的index.html路径
```
/// @param webUrl 在线网页的url
/// @return 对应的本地index文件路径，没有时返回nil
- (NSURL *_Nullable)getFileURL:(NSURL *)webUrl;

```
## 作者
&emsp;&emsp; [货拉拉移动端技术团队](https://juejin.cn/user/1768489241815070)
## 许可证
&emsp;&emsp;采用Apache2.0协议，详情参考[LICENSE](LICENSE)

