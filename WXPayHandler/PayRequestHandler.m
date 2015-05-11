//
//  PayRequestHandler.m
//  WXpay_v3_demo
//
//  Created by HeHui on 15/5/8.
//  Copyright (c) 2015年 HeHui. All rights reserved.
//

#import "PayRequestHandler.h"
#import "WXConfigues.h"
#import "CommonUtil.h"
#import "WXPayXMLParser.h"
@implementation PayRequestHandler
{
    NSString *_payUrl;   //预支付网关地址
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _payUrl = @"https://api.mch.weixin.qq.com/pay/unifiedorder";
    }
    return self;
}


// 创建package签名
- (NSString *)createMD5Sign:(NSDictionary *)dict
{
    NSMutableString *contentString = [NSMutableString string];
    NSArray *keys = [dict allKeys];
    //按字母顺序排序
    NSArray *sortArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    // 拼接字符串
    for (NSString *key in sortArray) {
        if (![dict[key] isEqualToString:@""] &&
            ![key isEqualToString:@"sign"] &&
            ![key isEqualToString:@"key"])
        {
            [contentString appendString:key];
            [contentString appendString:@"="];
            [contentString appendString:dict[key]];
            [contentString appendString:@"&"];      //样式类似于 name=yourSister&age=18&isPretty=yes
        }
    }
    // 添加key 商户API密钥
    [contentString appendFormat:@"key=%@",__WXpaySignKey];
    
    // 得到MD5加密后的 sign 签名
    NSString *md5Sign = [CommonUtil md5:contentString];

    return md5Sign;
}

// 获取package带参数的签名包
- (NSString *) getPackage:(NSDictionary *)dict
{
    NSString *sign = [self createMD5Sign:dict];               //创建签名
    NSMutableString *reqParmarXMLStr = [NSMutableString string];
    
    //生成XML的package
    NSArray *keys = [dict allKeys];
    [reqParmarXMLStr appendString:@"<xml>\n"];                //开始 <xml>
    for (NSString *key in keys) {
        [reqParmarXMLStr appendFormat:@"<%@>",key];           //元素开始  例如 <name>
        [reqParmarXMLStr appendFormat:@"%@",dict[key]];       // 值
        [reqParmarXMLStr appendFormat:@"</%@>\n",key];        //元素结束  例如 </name>
    }
    [reqParmarXMLStr appendFormat:@"<sign>%@</sign>\n",sign]; //将签名sign 放入<sign>中
    [reqParmarXMLStr appendString:@"</xml>"];                 //结束 </xml>
    
    
    return [NSString stringWithString:reqParmarXMLStr];
}

// 提交预支付
- (void) sendPrepayWithDict:(NSDictionary *)dict completion:(void(^)(NSString *resultPrepayID,ErrorCode errCode)) completion
{
    
    //获取提交支付的签名包
    NSString * postStr = [self getPackage:dict];
    
    //异步请求 返回数据
    [self httpRequestWithUrl:_payUrl method:@"Post" parmars:postStr completion:^(NSData *responseData, NSError *error) {
       
        if (error != nil) {
            NSLog(@"error = %@",error);
            completion(nil,ConnectionErr);
        }
        else {
            [[WXPayXMLParser sharedParser] parsingFromData:responseData resultDictionary:^(NSDictionary *resultDict) {
                //判断返回值
                NSString *return_code = [resultDict objectForKey:@"return_code"];
                NSString *result_code = [resultDict objectForKey:@"result_code"];
                
                if ([return_code isEqualToString:@"SUCCESS"]) //返回数据成功
                {
                    NSString *sign  = [self createMD5Sign:resultDict];       // 创建签名
                    NSString *send_sign =[resultDict objectForKey:@"sign"] ; // 获取返回的签名
                    if ([sign isEqualToString:send_sign]) // 判断签名是否和返回一致，（验证签名）
                    {
                        if ([result_code isEqualToString:@"SUCCESS"])  //验证业务处理状态
                        {
                            NSString *prePayID = [resultDict objectForKey:@"prepay_id"];
                            completion(prePayID,0);
                        }
                        else {
                            completion(nil,ResultError);   // 业务状态错误

                        }
                    }
                    else {
                        completion(nil,SignError);         // 服务器返回签名错误
                    }
                }
                else {
                    completion(nil,APIError);              // 接口错误
                }
            }];
        }
    }];
}


- (void) sendPayWithOrderName:(NSString *)orderName
                   OrderPrice:(NSString *)orderPrice
                   OutorderNo:(NSString *)outOrderNo
                   Completion:(void(^)(NSDictionary *resultDict,ErrorCode erCode)) completion
{
    
    NSString *nonceStr = [self getNonceStr];          // 获取一个随机串
    NSString *deviceInof = @"thisApp_user01";         // 这里看你是否需要获取用户的设备号或者是 店铺号码 给的是个例子
    NSString *ipAddr = [CommonUtil getIPAddress:YES]; //获取主机IP地址，本手机的，YES是 ipv4
    
    NSMutableDictionary *packageParams = [NSMutableDictionary dictionary];
    
    [packageParams setObject:__WXappID forKey:@"appid"];             //开放平台 appid
    [packageParams setObject:__WXmchID forKey:@"mch_id"];            //商户号
    [packageParams setObject:deviceInof forKey:@"device_info"];      //支付设备号或门店号
    [packageParams setObject:nonceStr forKey:@"nonce_str"];          //随机串  防重发
    [packageParams setObject:@"APP" forKey:@"trade_type"];           //支付类型 固定为APP
    [packageParams setObject:orderName forKey:@"body"];             //订单描述，展示给用户
    [packageParams setObject:__WX_NOTIFY_URL forKey:@"notify_url"];  //支付结果异步通知 --- 就是微信会把结果通过这个url传给你的服务器
    [packageParams setObject:outOrderNo forKey:@"out_trade_no"];   //商户订单号，不是自己内部的订单号，是微信支付记录的订单号
    [packageParams setObject:ipAddr forKey:@"spbill_create_ip"];     //发起支付的机器ip地址
    [packageParams setObject:orderPrice forKey:@"total_fee"];       //订单金额，单位是 --分--， 坑爹如果是小数会有错误，可能会崩溃
    
    [self sendPrepayWithDict:packageParams completion:^(NSString *resultPrepayID, ErrorCode errCode) {
        if (errCode == 0) {
            if (resultPrepayID != nil) {
                // 获取到prePayID后 进行第二次签名
                NSString *package,*timeStamp,*nonceStr;
                // 设置支付参数
                time_t now;
                time(&now);
                timeStamp = [NSString stringWithFormat:@"%ld",now];
                nonceStr = [self getNonceStr];
                package = @"Sign=WXPay"; //重新按提交格式组包，微信客户端暂只支持package=Sign=WXPay格式，须考虑升级后支持携带package具体参数的情况
                
                // 第二次签名参数列表
                NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
                [signParams setObject:__WXappID           forKey:@"appid"];
                [signParams setObject:nonceStr            forKey:@"noncestr"];
                [signParams setObject:package             forKey:@"package"];
                [signParams setObject:__WXmchID           forKey:@"partnerid"];
                [signParams setObject: timeStamp          forKey:@"timestamp"];
                [signParams setObject: resultPrepayID     forKey:@"prepayid"];
                
                // 生成签名
                NSString *sign = [self createMD5Sign:signParams];
                
                [signParams setObject:sign                forKey:@"sign"];
                
                completion(signParams,0);
            }
            else {
                completion(nil,PrepayIDEmpty);
            }
        }
        else {
            completion(nil,errCode);
        }
    }];
}

- (void) startWXPayWithOrderName:(NSString *)orderName
                      OrderPrice:(NSString *)orderPrice
                      OutorderNo:(NSString *)outOrderNo
                      Completion:(void(^)(NSDictionary *resultDict,NSString * errorMsg)) completion
{
    [self sendPayWithOrderName:orderName OrderPrice:orderPrice OutorderNo:outOrderNo Completion:^(NSDictionary *resultDict, ErrorCode erCode) {
        if (resultDict) {
            completion(resultDict,@"");
        }
        else {
            NSString *errMsg = @"";
            switch (erCode) {
                case ResultError:
                    errMsg = @"业务状态错误";
                    break;
                case SignError:
                    errMsg = @"服务器返回签名验证错误";
                    break;
                case APIError:
                    errMsg = @"接口错误";
                    break;
                case PrepayIDEmpty:
                    errMsg = @"预支付ID为空";
                    break;
                case ConnectionErr:
                    errMsg = @"请检查网络";
                    break;
                default:
                    break;
            }
            completion(nil,errMsg);
        }
    }];
}


/**
 *  获取32位内的随机串, 防重发
 *
 *  注意：商户系统内部的订单号,32个字符内、可包含字母,确保在商户系统唯一
 */
- (NSString *)getNonceStr
{
    return [CommonUtil md5:[NSString stringWithFormat:@"%d",arc4random()%10000]];
}


////http同步 请求
//- (NSData *) httpSend:(NSString *)url method:(NSString *)method data:(NSString *)data
//{
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
//    //设置提交方式
//    [request setHTTPMethod:method];
//    //设置数据类型
//    [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
//    //设置编码
//    [request setValue:@"UTF-8" forHTTPHeaderField:@"charset"];
//    //如果是POST
//    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    NSError *error;
//    //将请求的url数据放到NSData对象中
//    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        
//    }];
//    return response;
//    //return [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
//}


#pragma mark --- 网络请求 ---
//http异步 请求
- (void) httpRequestWithUrl:(NSString *)url method:(NSString *)method parmars:(NSString *)parmrsString completion:(void(^)(NSData *responseData,NSError *error)) completion;
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
    //设置提交方式
    [request setHTTPMethod:method];
    //设置数据类型
    [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    //设置编码
    [request setValue:@"UTF-8" forHTTPHeaderField:@"charset"];
    //如果是POST
    [request setHTTPBody:[parmrsString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        completion(data,connectionError);
    }];

}



@end
