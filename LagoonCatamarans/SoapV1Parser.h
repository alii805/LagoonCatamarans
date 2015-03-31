//
//  SoapV1Parser.h
//  Demo_API_calls
//
//  Created by mac2 ccc on 01/06/13.
//  Copyright (c) 2013 mac2 ccc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SuccessCallBack)(id anObject);
typedef void (^FailureCallBack)(id anError);

@interface SoapV1Parser : NSObject <NSXMLParserDelegate>
{
    NSMutableData *webdata;
    SEL targetSelector;
    NSObject *MainHandler;
    
    NSString *strTerminatingTag;
    NSArray *arrayKey;
    NSMutableArray *arrResult;
    
    BOOL isBunchData;
    
    SuccessCallBack doneCallback;
    FailureCallBack failedCallback;
    
}

-(void)SoapRequest:(NSString* )strBaseurl apiName:(NSString *)methodName withBodyData:(NSDictionary *)dataDic onSucces:(SuccessCallBack)done onFail:(FailureCallBack)fail isBunch:(BOOL)responseType;

@end
