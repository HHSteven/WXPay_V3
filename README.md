# WXPay_V3
微信支付V3版本 demo

1. 导入库文件：SystemConfiguration.framework , liba.dylib, libsqlite3.0.dylib, libc++.dylib(这个不添加要报错)，如果有更新请参照微信支付官方Demo
   在 WXPayConfiguration.h 中添加自己的app 微信支付相关参数。
2. AppDelegate 中配置 demo中有
3. 在调用的支付的 viewcontroller 中 包含 WXPayConfiguration.h 和 "PayRequestHandler.h"，"WXApi.h"


// 传入参数  订单名称，总价 ,外部订单号。

    [ph startWXPayWithOrderName:@"支付测试" OrderPrice:@"1" OutorderNo:@"111111" Completion:^(NSDictionary *resultDict, NSString *errorMsg) {
        
        sender.enabled = YES;
        
        if (errorMsg.length == 0) {
            NSMutableString *stamp  = [resultDict objectForKey:@"timestamp"];
            PayReq* req             = [[PayReq alloc] init];
            req.openID              = [resultDict objectForKey:@"appid"];
            req.partnerId           = [resultDict objectForKey:@"partnerid"];
            req.prepayId            = [resultDict objectForKey:@"prepayid"];
            req.nonceStr            = [resultDict objectForKey:@"noncestr"];
            req.timeStamp           = stamp.intValue;
            req.package             = [resultDict objectForKey:@"package"];
            req.sign                = [resultDict objectForKey:@"sign"];
            
            [WXApi sendReq:req];
        }
        else {
            UIAlertView *alt =[[UIAlertView alloc] initWithTitle:@"提示" message:errorMsg delegate:self cancelButtonTitle:@"朕知道了" otherButtonTitles: nil];
            [alt show];
        }
    }];


                     ===========================================================
                           微信支付太坑， 此demo仅供参考。如有错误欢迎指正。
                     ===========================================================

