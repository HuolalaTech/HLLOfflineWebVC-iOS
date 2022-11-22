<img src=Image/title.png width=100% height=100% />

[![license](https://img.shields.io/hexpm/l/plug.svg)](https://www.apache.org/licenses/LICENSE-2.0)
![Pod Version](https://img.shields.io/badge/pod-v1.0.0-green.svg)
![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)
![Language](https://img.shields.io/badge/language-ObjectC-green.svg)
[![wiki](https://img.shields.io/badge/Wiki-open-brightgreen.svg)](https://juejin.cn/post/7103348563479887885)

> [中文文档](README_CN.md) | 
> [Introduction](https://juejin.cn/post/7103348563479887885)

---
 HLLOfflineWebVC is a lightweight and high-performance hybrid framework developed by HUOLALA mobile team, which is intended to improve the load speed of websites on mobile phone. It base on [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview/) at iOS system.  
 HLLOfflineWebVC can cache html, css, js, png and other static resource on the disk. When the app load the web page, it directly load the resource from disk and reduce network request. You can get more details from the [article](https://juejin.cn/post/7103348563479887885).
 
## Before VS After Using HLLOfflineWebVC

 | |Before Using HLLOfflineWebVC |   After Using HLLOfflineWebVC
|--|:-------------------------:|:-------------------------:
| Time Cost|2s |   1s
|Movie|<img src=Image/1.gif  />  | <img src=Image/2.gif  />



## Features
 - Safe and reliable: no hook and no private API,  three degrade strategy.
 - Easy to maintain: three layer structure and modular design.
 - Fully functional: it contains H5 offline resource managing, url and offline resource mapping config, data reporting, debug tool. 
        

## Requirements
- iOS 9.0 or later
- Xcode 11.0 or later
- CocoaPods 1.11.2 or later

## Get Started
1) Download the code.
2) Enter the 'Example' folder, enter command 'pod install' to install 3rd-party libraries.
3) Open the project 'HLLOfflineWebVC.xcworkspace' and built it by Xcode.  If you complile and run the demo successfully, you will see the UI below:

<img src=Image/1.jpg width=30% height=30% /> <img src=Image/2.png width=30% height=30%  />  <img src=Image/3.png width=30% height=30% />


## Communication
- If you find a bug, open an issue.
- If you have a feature request, open an issue.
- If you want to contribute, submit a pull request.
## Architecture
- OfflineWebPackage

   The core module of HLLOfflineWebVC. 
- OfflineWebDevTool

     An useful tool to Debug the offline web.
- OfflineWebBisNameMatch

   Connect the web page with offline resource by config.
- OfflineWebUtils

   An inner API used by other module.
## How To Use
If you want to bring the code into your project, you need to do the following:

###  Develop A HTTP Service
 1) HTTP Request

    https://huolala.cn/queryOffline?clientType=iOS&clientVer=1.0.0&offlineZipVer=1.0.0&bisName=xx
      
   &emsp;requet data parameters description:

| parameter name         | parameter meaning                     | note                                |
|------------------|-------------------------------|-------------------------------------|
| clientType               | operating system type                     | iOS，Android                        |
| clientVersion    | app version                   |  eg: 1.0                                   |
| bisName          | unique identifier of your offline web page    |   eg: act3-offline-package-test                |
| offlineZipVer    | the local offline web file version        | 0 means no offline web cache            |
   
   
   
   &emsp;respond data format is a json，parameters description:

| parameter name       | parameter meaning     |      note                                                                               |
|--------------|-------------|--------------------------------------------------------------------------------------------|
| bisName      | unique identifier of your offline web page       | eg: act3-offline-package-test                                                                                           |
| result       | query result        | -1: disable offline web, 0: no update, 1: has new version   |
| url          | zip file download url   | if no update, the url is null                                                                           |
| refreshMode  |notify client how to update     | 0:update next(default)   1:update immediately                                                           |
| version      | offline web pages version  | eg: 25609-j56gfa                               |

 2) Cross Origin

    When an offline web page make a network request, the origin is null，should modify your gateway or server to support.

###  Modify HTML And JS File
- use relative path, no absolute path.
- cookie、local storage should support the situation that host is null.
- add a file to describe the offline web version .the file name is ".offweb.json" and the content is:
{ "bisName": "xxx", "ver": "xxx" }

## Bring The Code Into Your Client 
### Install Completely
 Install all the modules in your project.
 1) Add the string " pod 'HLLOfflineWebVC' " in your pod file.

 2) Call the initial function.
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
 3) Config the dictionary. 

    "OffwebConfigDict" is a dictionary from json, configure the degrade strategy, auto add offweb parameters to url:
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
| parameter name       | parameter meaning     |      required or optional                                                                               |
|--------------|-------------|--------------------------------------------------------------------------------------------|
| switch      | 1 open，0 close     | required                                                                                           |
| predownloadlist       | If you need download an offline web page, add the business name     | optional  |
| disablelist          | disable some offline web page   | optional                                                                           |
| rules  |when the host and path match the rules, webview will add 'offweb=uappweb' to you url    | optional                                                           |
 4) Modify webview container.

Implement the function bellow in your basic webview container. Then edit the parent class of HLLOfflineWebVC.
``` 
 - (BOOL)webview:(WKWebView *)webview shouldStartLoadWithRequest:(NSURLRequest *)request {
        return YES;
}
```
   Declare WKWebview  delegate ` <WKUIDelegate,WKNavigationDelegate> ` in the head file.

### Install Core Module 

  Just install the core module that not contains 'HLLOfflineWebVC', the CocoaPods command is:    pod 'HLLOfflineWebVC/OfflineWebPackage' .
The main API :
 1) Check Update API
``` 
 //@param bisName： unique identifier of your offline web page 
 //@param resultBlock：the result block

 - (void)checkUpdate:(NSString *)bisName result:(HLLOfflineWebResultBlock)resultBlock;
``` 
 2) Get the Local File Path of Offline Web
```
 //@param webUrl: online web page url 
 //@return: the local file path of "index.html". If not exist, return nil
 
- (NSURL *_Nullable)getFileURL:(NSURL *)webUrl;
``` 
## Author 
 [HUOLALA mobile technology team](https://juejin.cn/user/1768489241815070).
## License
 HLLOfflineWebVC is released under the Apache 2.0 license. See [LICENSE](LICENSE) for details.
