#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"
#import "GCDWebServerURLEncodedFormRequest.h"
#import "LocalServerTestController.h"

#define ServerBisName @"act3-offline-package-test"
#define ServerVersion @"25609-j56gfa"
@interface LocalServerTestController () <GCDWebServerDelegate> {
    GCDWebServer *_localServer;
}
@end
@implementation LocalServerTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self startLocalServer];
}

- (NSString *)dictToJsonStr:(NSDictionary *)dict {
    NSString *jsonString = nil;
    if ([NSJSONSerialization isValidJSONObject:dict]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (error) {
            NSLog(@"Error:%@", error);
        }
    }
    return jsonString;
}

- (void)startLocalServer {
    _localServer = [[GCDWebServer alloc] init];
    _localServer.delegate = self;
    //设置监听
    [_localServer addHandlerForMethod:@"GET"
                                 path:@"/offweb" //接口名
                         requestClass:[GCDWebServerURLEncodedFormRequest class]
                         processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request) {
                             GCDWebServerDataResponse *response;
                             //获取请求中的参数（body）
                             NSMutableDictionary *dict = [NSMutableDictionary new];
                             if ([request.query[@"bisName"] isEqualToString:ServerBisName] &&
                                 [request.query[@"offlineZipVer"] isEqualToString:ServerVersion]) {
                                 [dict setObject:request.query[@"bisName"] forKey:@"bisName"];
                                 [dict setObject:[NSNumber numberWithInt:0] forKey:@"result"];

                             } else if ([request.query[@"bisName"] isEqualToString:ServerBisName]) {
                                 [dict setObject:request.query[@"bisName"] forKey:@"bisName"];
                                 [dict setObject:[NSNumber numberWithInt:1] forKey:@"result"];
                                 [dict setObject:ServerVersion forKey:@"version"];
                                 [dict setObject:[NSString stringWithFormat:@"http://localhost:5555/resource/%@.zip",
                                                                            ServerBisName]
                                          forKey:@"url"];
                             } else {
                                 [dict setObject:request.query[@"bisName"] == nil ? @"" : request.query[@"bisName"]
                                          forKey:@"bisName"];
                                 [dict setObject:[NSNumber numberWithInt:-1] forKey:@"result"];
                             }
                             response = [GCDWebServerDataResponse responseWithText:[self dictToJsonStr:dict]];
                             //响应头设置，跨域请求需要设置，只允许设置的域名或者ip才能跨域访问本接口）
                             [response setValue:@"*" forAdditionalHeader:@"Access-Control-Allow-Origin"];

                             [response setValue:@"Content-Type" forAdditionalHeader:@"Access-Control-Allow-Headers"];

                             return response;
                         }];

    [_localServer addHandlerForMethod:@"GET"
                            pathRegex:@"/resource" //接口名
                         requestClass:[GCDWebServerURLEncodedFormRequest class]
                         processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request) {
                             NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
                             NSLog(@"bundlepath %@ ", bundlePath);
                             NSString *path = [bundlePath stringByAppendingString:request.path];
                             NSData *fileData = [NSData dataWithContentsOfFile:path];
                             GCDWebServerDataResponse *response =
                                 [GCDWebServerDataResponse responseWithData:fileData contentType:@"application/zip"];
                             if (fileData == nil) {
                                 return [GCDWebServerDataResponse responseWithText:@"file not exist"];
                             }
                             return response;
                         }];

    //设置监听端口
    [_localServer startWithPort:5555 bonjourName:nil];
    NSLog(@"Visit %@ in your web browser", _localServer.serverURL);
}

- (void)webServerDidStart:(GCDWebServer *)server {
    NSLog(@"本地服务启动成功");
}

@end
