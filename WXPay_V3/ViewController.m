//
//  ViewController.m
//  WXPay_V3
//
//  Created by HeHui on 15/5/11.
//  Copyright (c) 2015年 HeHui. All rights reserved.
//

#import "ViewController.h"
#import "PayRequestHandler.h"
#import "WXApi.h"
#import "WXPayConfiguration.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}

//添加观察者
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxpayResultNotification:) name:__WXORDER_PAY_NOTIFICATION object:nil];
}

// 注销观察者
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:__WXORDER_PAY_NOTIFICATION object:nil];
}

- (IBAction)wxpayTestBtn:(UIButton *)sender {
#if TARGET_IPHONE_SIMULATOR
    
    //模拟器
    UIAlertView *alt =[[UIAlertView alloc] initWithTitle:@"提示" message:@"模拟器无法调用微信！" delegate:self cancelButtonTitle:@"朕知道了" otherButtonTitles: nil];
    [alt show];
    
#elif TARGET_OS_IPHONE
    
    //真机
    sender.enabled = NO;
    // hud --- 正在提交。。。。 防止多次操作
    
    PayRequestHandler *ph = [[PayRequestHandler alloc] init];
    
    
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

    
#endif
    
    
    
    
}

- (void)wxpayResultNotification:(NSNotification *)notice
{
    NSString *result = notice.object;
    
    NSString *msg = @"";
    
    if ([result isEqualToString:__WXORDER_PAY_SUCCESS]) {
        //支付成功 。。。
        // 这里 最好还能去服务器请求一下数据 看看是否已经支付成功

        
        msg = @"支付成功";
        
    }
    else if ([result isEqualToString:__WXORDER_PAY_FAILED]) {
        //支付失败 。。。
        
        msg = @"支付失败";

    }
    else {
        //error;
        msg = @"an error accured";
    }
    
    UIAlertView *alt =[[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"朕知道了" otherButtonTitles: nil];
    [alt show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
