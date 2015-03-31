//
//  EventAPICall.h
//  Soap_API
//
//  Created by Test on 20/09/13.
//  Copyright (c) 2013 Test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoapV1Parser.h"
#import "AFNetworking.h"

@interface EventAPICall : NSObject




+(void)apiCallWithName:(NSString *)method parameters:(NSDictionary *)dicData success:(SuccessCallBack)success failure:(FailureCallBack)fail;

@end
