//
//  EventAPICall.m
//  Soap_API
//
//  Created by Test on 20/10/14.
//  Copyright (c) 2014 Test. All rights reserved.
//

#import "EventAPICall.h"
#import "XMLReader.h"
#import "AFHTTPClient.h"


#define BaseURL @"http://lagooncatamarans.org/"

@implementation EventAPICall

+(void)apiCallWithName:(NSString *)method parameters:(NSDictionary *)dicData success:(SuccessCallBack)success failure:(FailureCallBack)fail
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BaseURL]];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:[NSString stringWithFormat:@"%@.php",method] parameters:dicData];
    
    NSLog(@"Final Url String %@",request);
    [request setTimeoutInterval:150];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Print the response body in text
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              
                              options:kNilOptions 
                              error:&error];
        
        NSString *strResponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Response: %@", strResponse);
        
        success(json/*[XMLReader dictionaryForXMLString:strResponse error:nil]*/);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        fail(error);
    }];
    [operation start];
}
@end
