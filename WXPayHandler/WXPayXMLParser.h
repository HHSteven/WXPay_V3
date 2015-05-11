//
//  WXPayXMLParser.h
//  WXpay_v3_demo
//
//  Created by HeHui on 15/5/8.
//  Copyright (c) 2015年 HeHui. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ParsingResultBlock)(NSDictionary *resultDict);

@interface WXPayXMLParser : NSObject <NSXMLParserDelegate>

+ (WXPayXMLParser *) sharedParser;

- (void )parsingFromData:(NSData *)data resultDictionary:(ParsingResultBlock ) resultBlock;


@end
