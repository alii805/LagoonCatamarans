//
//  SoapV1Parser.m
//  Demo_API_calls
//
//  Created by mac2 ccc on 01/06/13.
//  Copyright (c) 2013 mac2 ccc. All rights reserved.
//

#import "SoapV1Parser.h"
#import "XMLReader.h"

@implementation SoapV1Parser




#define kSoapEnvelop(body) [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body>%@</soap:Body></soap:Envelope>",body];

-(void)SoapRequest:(NSString* )strBaseurl apiName:(NSString *)methodName withBodyData:(NSDictionary *)dataDic onSucces:(SuccessCallBack)done onFail:(FailureCallBack)fail isBunch:(BOOL)responseType
{
    arrResult = [[NSMutableArray alloc] init];
    
    isBunchData = responseType;
    
    doneCallback = done;
    failedCallback = fail;
    
    NSString *baseUrl = @"http://staging.sigmasolve.net/EventApp/EventAppService.asmx";
    NSURL *url = [NSURL URLWithString:baseUrl];
    
    NSString *strSoapEnvelop = kSoapEnvelop([self createSoapBody:dataDic apiName:methodName]);
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%i", (int)[strSoapEnvelop length]];
    [theRequest addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *strSoapAction = [NSString stringWithFormat:@"http://tempuri.org/%@",methodName];
    
    [theRequest addValue:strSoapAction forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [strSoapEnvelop dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *theConnection = [[NSURLConnection alloc]initWithRequest:theRequest delegate:self];
    
    
    //    POST /EventApp/EventAppService.asmx HTTP/1.1
    //     Host: staging.sigmasolve.net
    //    Content-Type: text/xml; charset=utf-8
    //    Content-Length: length
    //     SOAPAction: "http://tempuri.org/RegisterUser"
    
    
    if (theConnection)
    {
        webdata = [[NSMutableData alloc] init];
    }
    else
    {
        NSLog(@"theConnection is NULL");
    }
}

-(NSString *)createSoapBody:(NSDictionary *)dictionary apiName:(NSString *)methodName
{
    NSString *strBody = @"";
    for (id key in [dictionary allKeys]) {
        
        NSString *strTag = [NSString stringWithFormat:@"<%@>%@</%@>",key,[dictionary valueForKey:key],key];
        strBody = [strBody stringByAppendingString:strTag];
    }
    
    NSString *strFinalBody = [NSString stringWithFormat:@"<%@ xmlns=\"http://tempuri.org/\">%@</%@>",methodName,strBody,methodName];
    return strFinalBody;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [webdata setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webdata appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"ERROR with theConkenction");
    failedCallback(@"Error with Connection");
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"DONE. Received Bytes: %d", (int)[webdata length]);
    
    NSDictionary *dicData = [XMLReader dictionaryForXMLData:webdata error:nil];
    doneCallback(dicData);
}

@end
