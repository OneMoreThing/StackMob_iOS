//
//  StackMobDataBridge.m
//  StackMobiOS
//
//  Created by Ryan Connelly on 10/9/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "STMDynamicDataProvider.h"
#import "StackMobRequest.h"
#import "StackMobPushRequest.h"

@implementation STMDynamicDataProvider

- (void) prepare
{
    
}

- (StackMobRequest *)request
{
    return [StackMobRequest request];
}

- (StackMobRequest *)userRequest
{
    return [StackMobRequest userRequest];
}

- (StackMobRequest *)requestForMethod:(NSString*)method
{
	return [StackMobRequest requestForMethod:method withHttpVerb:GET];
}	

- (StackMobRequest *)requestForMethod:(NSString*)method withHttpVerb:(SMHttpVerb)httpVerb
{
	return [StackMobRequest requestForMethod:method withObject:nil withHttpVerb:httpVerb];
}

- (StackMobRequest *)requestForMethod:(NSString*)method withObject:(id)object  withHttpVerb:(SMHttpVerb)httpVerb
{
	return [StackMobRequest requestForMethod:method withObject:object withHttpVerb:httpVerb];
}

+ (StackMobRequest *)requestForMethod:(NSString*)method withArguments:(NSDictionary*)arguments withHttpVerb:(SMHttpVerb)httpVerb;
{
    return [StackMobRequest requestForMethod:method withArguments:arguments withHttpVerb:httpVerb];
}

- (StackMobRequest *)requestForMethod:(NSString *)method withData:(NSData *)data{
    return [StackMobRequest requestForMethod:method withData:data];
}

- (StackMobRequest *)userRequestForMethod:(NSString *)method withHttpVerb:(SMHttpVerb)httpVerb
{
	return [StackMobRequest userRequestForMethod:method withObject:nil withHttpVerb:httpVerb];    
}

- (StackMobRequest *)userRequestForMethod:(NSString*)method withObject:(id)object withHttpVerb:(SMHttpVerb)httpVerb
{
	return [StackMobRequest userRequestForMethod:method withObject:object withHttpVerb:httpVerb];
}

- (StackMobPushRequest *)pushRequestWithArguments:(NSDictionary*)arguments withHttpVerb:(SMHttpVerb) httpVerb
{
    return [StackMobRequest pushRequestWithArguments:arguments withHttpVerb:httpVerb];
}

- (StackMobPushRequest *)pushRequest
{
    return [StackMobPushRequest request];
}

- (StackMobBulkRequest *)bulkRequestForMethod:(NSString *)method withObject:(id)object withHttpVerb:(SMHttpVerb) httpVerb
{
    return [StackMobBulkRequest requestForMethod:method withArguments:object withHttpVerb:httpVerb]; 
}

- (StackMobBulkRequest *)bulkRequest
{
    return [StackMobBulkRequest request];
}

@end
