//
//  WXPayXMLParser.m
//  WXpay_v3_demo
//
//  Created by HeHui on 15/5/8.
//  Copyright (c) 2015年 HeHui. All rights reserved.
//

#import "WXPayXMLParser.h"

@implementation WXPayXMLParser
{
    ParsingResultBlock _resultBlock;
    NSXMLParser *_xmlParser;
    NSMutableString *_contentString;
    NSMutableDictionary *_resultDict;
}


+ (WXPayXMLParser *)sharedParser
{
    static  WXPayXMLParser *globe_Paser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (globe_Paser == nil) {
            globe_Paser = [[WXPayXMLParser alloc] init];
        }
    });
    return globe_Paser;
}


- (void )parsingFromData:(NSData *)data resultDictionary:(ParsingResultBlock ) resultBlock;
{
    if (_xmlParser) {
        _xmlParser = nil;
    }
    if (_contentString) {
        _contentString = nil;
    }
    if (_resultBlock) {
        _resultBlock = nil;
    }
    if (_resultDict) {
        [_resultDict removeAllObjects];
        _resultDict = nil;
    }

    _xmlParser = [[NSXMLParser alloc] initWithData:data];
    _xmlParser.delegate = self;
    _resultBlock = resultBlock;
    _contentString = [NSMutableString string];
    _resultDict = [NSMutableDictionary dictionary];
    [_xmlParser parse];
}


#pragma mark --- NSXMLDelegate ---

//开始解析
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //每次遇到内容string 将_contentString 设置成string (这个string 元素对应的值）
    [_contentString setString:string];

}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    //每次遇到结束标签，将内容和标签做成键值对存储在_resultDict中
    if( ![_contentString isEqualToString:@"\n"] && ![elementName isEqualToString:@"root"])
    {
        [_resultDict setObject: [_contentString copy] forKey:elementName];
    }
}

// 结束解析
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    //结束将_resultDict 带出
    _resultBlock(_resultDict);
    _contentString = nil;
    _xmlParser = nil;
    
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    NSLog(@"解析失败,error = %@",validationError);
   
}

@end
