//
//  AppDelegate.m
//  WXPay_V3
//
//  Created by HeHui on 15/5/11.
//  Copyright (c) 2015年 HeHui. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if (__WXappID.length == 0 ) {
        UIAlertView *alt = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请配置微信支付参数" delegate:self cancelButtonTitle:@"朕知道了" otherButtonTitles: nil];
        [alt show];
        return YES ;
    }
    
    [WXApi registerApp:__WXappID withDescription:@"微信测试"];

    
    // Override point for customization after application launch.
    return YES;
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return  [WXApi handleOpenURL:url delegate:self];
}

#pragma mark --- WXApiDelegate --

- (void)onResp:(BaseResp *)resp
{
    
    NSString *strMsg = [NSString stringWithFormat:@"错误代码：%d",resp.errCode];
    
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        //发送媒体消息结果
    }
    else if ([resp isKindOfClass:[PayResp class]]) {
        // 支付返回的结果，这里是给客户端返回的，实际结果需要去微信服务端查询
        switch (resp.errCode) {
            case WXSuccess:
            {
                strMsg = @"支付结果：成功！";
                [[NSNotificationCenter defaultCenter] postNotificationName:__WXORDER_PAY_NOTIFICATION object:__WXORDER_PAY_SUCCESS];
                
            }
                break;
                
            default:
            {
                strMsg = [NSString stringWithFormat:@"支付结果：失败！ returnCode == %d,returnStr == %@",resp.errCode,resp.errStr];
                [[NSNotificationCenter defaultCenter] postNotificationName:__WXORDER_PAY_NOTIFICATION object:__WXORDER_PAY_FAILED];
                // 如果你需要把错误代码也带过去，重新定义一个 通知；
            }
                break;
        }
    }
    NSLog(@"strMsg = %@",strMsg);
}


@end
