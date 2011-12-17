// Copyright 2011 StackMob, Inc
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "STMRestkitDataProvider.h"
#import "STMRestKitRequest.h"
#import "StackMobRequest.h"
#import "StackMobPushRequest.h"
#import "STMRestKitConfiguration.h"
#import "StackMob.h"
#import "StackMobSession.h"
#import "STMClient.h"
#import "STMObjectRouter.h"

@interface STMRestkitDataProvider (Private)
- (void) prepareRouter:(RKObjectRouter *)router withRequest:(STMRestKitRequest *)request;
@end

@implementation STMRestkitDataProvider
@synthesize restKitConfiguration;

+ (void) initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSSet* JSONParserClassNames = [NSSet setWithObjects:@"RKJSONParserJSONKit", @"RKJSONParserYAJL", @"RKJSONParserSBJSON", @"RKJSONParserNXJSON", nil];    
        for (NSString* parserClassName in JSONParserClassNames) {
            Class parserClass = NSClassFromString(parserClassName);
            if (parserClass) {
                [[RKParserRegistry sharedRegistry] setParserClass:parserClass forMIMEType:@"application/json charset=utf-8"];
                break;
            }
        }
    });
}

- (id) initWithConfiguration:(STMRestKitConfiguration *)config
{
    self = [super init];
    if(self)
    {
        restKitConfiguration = [config retain];
    }
    return self;
}

+ (id) dataProviderWithConfiguration:(STMRestKitConfiguration *)config
{
    STMRestkitDataProvider *r = [[STMRestkitDataProvider alloc] initWithConfiguration:config];
    return [r autorelease];
}


- (void) prepareRequest:(STMRestKitRequest *)request
{
    if([self.restKitConfiguration client])
        request.objectManager.client = [self.restKitConfiguration client];
    
    if([self.restKitConfiguration mappingProvider])
        request.objectManager.mappingProvider = (RKObjectMappingProvider *)[self.restKitConfiguration mappingProvider];
    
    if([self.restKitConfiguration router])
    {
        request.objectManager.router = [self.restKitConfiguration router];
        [self prepareRouter:request.objectManager.router withRequest:request];
    }
    
    request.objectManager.inferMappingsFromObjectTypes = self.restKitConfiguration.inferMappingsFromObjectTypes;
}

/* Appends the base path to the relative path. Required because RestKit OAuth expects 
   the full relative path. */
- (void) prepareRouter:(RKObjectRouter *)router withRequest:(STMRestKitRequest *)request
{   
    StackMobSession *sess = [[StackMob stackmob] session];
    NSString *path = [[NSURL URLWithString:sess.apiURL] relativePath];    
    if([request userBased])
    {
        [path stringByAppendingFormat:@"/%@",sess.userObjectName];
    }
    NSMutableDictionary *routes = [request.objectManager.router routes];
    for( NSString *className in [routes allKeys] )
    {
        NSMutableDictionary *classRoutes = [routes objectForKey:className];
        for( NSString *method in [classRoutes allKeys] )
        {
            NSMutableDictionary *routeEntry = [classRoutes objectForKey:method];
            NSString *resourcePath = [routeEntry objectForKey:@"resourcePath"];
            if(![path isEqualToString:resourcePath])  // prepend the base path if needed
            {
                NSString *newResourcePath = [path stringByAppendingString:resourcePath];
                // update the resource path with the new value;
                [routeEntry setObject:newResourcePath forKey:@"resourcePath"];
            }
        }
    }
}

- (StackMobRequest *)request
{
    STMRestKitRequest *request = [STMRestKitRequest request];
    [self prepareRequest:request];
    return request;
}

- (StackMobRequest *)userRequest
{
    return [STMRestKitRequest userRequest];
}

- (StackMobRequest *)requestForMethod:(NSString*)method
{
	return [STMRestKitRequest requestForMethod:method withHttpVerb:GET];
}	

- (StackMobRequest *)requestForMethod:(NSString*)method withHttpVerb:(SMHttpVerb)httpVerb
{
	return [STMRestKitRequest requestForMethod:method withObject:nil withHttpVerb:httpVerb];
}

- (StackMobRequest *)requestForMethod:(NSString*)method withObject:(id)object  withHttpVerb:(SMHttpVerb)httpVerb
{
	STMRestKitRequest *request =  [STMRestKitRequest requestForMethod:method withObject:object withHttpVerb:httpVerb];
    [self prepareRequest:request];
    return request;
}

- (StackMobRequest *)requestForMethod:(NSString *)method withData:(NSData *)data{
    return [STMRestKitRequest requestForMethod:method withData:data];
}

- (StackMobRequest *)userRequestForMethod:(NSString *)method withHttpVerb:(SMHttpVerb)httpVerb
{
	return [STMRestKitRequest userRequestForMethod:method withObject:nil withHttpVerb:httpVerb];    
}

- (StackMobRequest *)userRequestForMethod:(NSString*)method withObject:(id)object withHttpVerb:(SMHttpVerb)httpVerb
{
	return [STMRestKitRequest userRequestForMethod:method withObject:object withHttpVerb:httpVerb];
}

/*
 * Create a request for an iOS PUSH notification
 @param arguments a dictionary of arguments including :alert, :badge and :sound
 */
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
    return (StackMobBulkRequest *)[self requestForMethod:method withObject:object withHttpVerb:httpVerb];
}

- (StackMobBulkRequest *)bulkRequest
{
    return (StackMobBulkRequest *)[self request];
}

- (void) dealloc
{
    [restKitConfiguration release];
    [super dealloc];
}

@end
