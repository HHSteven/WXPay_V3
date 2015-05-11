//
//  WXPayConfiguration.h
//  WXPay_V3
//
//  Created by HeHui on 15/5/11.
//  Copyright (c) 2015年 HeHui. All rights reserved.
//

#ifndef WXPay_V3_WXPayConfiguration_h
#define WXPay_V3_WXPayConfiguration_h


// appID
#define __WXappID @"wxae0f12fb043950fc"  //lt

// appSecret
#define __WXappSecret @"93273de205aa41a9d4d30434d9f9a39e" //lt

//商户号，填写商户对应参数
#define __WXmchID @"1230600601" //lt

//商户API密钥，填写相应参数
#define __WXpaySignKey @"7b206c79907dad963ca6ac5a8abf1c28" //lt

//支付结果回调页面
#define __WX_NOTIFY_URL      @"http://wxpay.weixin.qq.com/pub_v2/pay/notify.v2.php"

//获取服务器端支付数据地址（商户自定义）
//#define SP_URL          @"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php"

//支付通知结果Key
#define __WXORDER_PAY_NOTIFICATION @"WXOrderPayNotification"

//支付成功
#define __WXORDER_PAY_SUCCESS @"wxpaySuccess"


//支付失败
#define __WXORDER_PAY_FAILED @"wxpayFailed"

#endif
