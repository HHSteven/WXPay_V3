//
//  PayRequestHandler.h
//  WXpay_v3_demo
//
//  Created by HeHui on 15/5/8.
//  Copyright (c) 2015年 HeHui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

typedef NS_ENUM(NSInteger, ErrorCode) {
    ResultError  = 1,                 //  业务状态错误
    SignError    = ResultError<<1,    //  服务器返回签名验证错误
    APIError     = ResultError<<2,    //  接口错误
    PrepayIDEmpty= ResultError<<3,    //  预支付ID为空
    ConnectionErr= ResultError<<4,    //  网络问题
};

@interface PayRequestHandler : NSObject


/**
 *  提交支付
 *
 *  @param orderName  订单名称
 *  @param orderPrice 订单金额   单位为分， 比如 10，是10分 0.1元
 *  @param outOrderNo 外部商户订单编号
 *  @param completion 返回的错误信息，如果为空为成功
 */
- (void) startWXPayWithOrderName:(NSString *)orderName
                      OrderPrice:(NSString *)orderPrice
                      OutorderNo:(NSString *)outOrderNo
                      Completion:(void(^)(NSDictionary *resultDict, NSString * errorMsg)) completion;
@end
