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

#import "StackMob.h"
#import "StackMobRequest.h"
#import "StackMobCookieStore.h"
#import "Reachability.h"
#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "StackMobAdditions.h"
#import "StackMobClientData.h"
#import "StackMobSession.h"
#import "StackMobPushRequest.h"
#import "NSData+JSON.h"
#import "SMFile.h"

@interface StackMobRequest (Private)
+ (RKRequestMethod)restKitVerbFromStackMob:(SMHttpVerb)httpVerb;
+ (SMHttpVerb)stackMobVerbFromRestKit:(RKRequestMethod)httpVerb;
- (void)setBodyForRequest:(OAMutableURLRequest *)request;
- (NSString*)getAcceptHeaderForVersion:(NSNumber *)version;
@end

@implementation StackMobRequest;

@synthesize delegate = mDelegate;
@synthesize isSecure = mIsSecure;
@synthesize result = mResult;
@synthesize connectionError = _connectionError;
@synthesize body;
@synthesize httpResponse = mHttpResponse;
@synthesize finished = _requestFinished;
@synthesize userBased;
@synthesize backingRequest = mBackingRequest;
@synthesize callback = mCallback;

# pragma mark - Memory Management
- (void)dealloc
{
	[self cancel];
	[mConnectionData release];
	[mConnection release];
	[mDelegate release];
	[mResult release];
	[mHttpResponse release];
    [mHeaders release];    
	[super dealloc];
}

# pragma mark - Initialization

+ (id)request	
{
	StackMobRequest *request = [[[StackMobRequest alloc] init] autorelease];
    request.backingRequest = [[[StackMob stackmob] client] requestWithResourcePath:nil delegate:request];
    return request;
}

+ (id)requestFromRestKit:(RKRequest*)req
{
    StackMobRequest *request = [StackMobRequest request];
    request.backingRequest = req;
    request.backingRequest.delegate = request;
    return request;
}

+ (id)userRequest
{
    StackMobRequest *request = [StackMobRequest request];
    request.userBased = YES;
    return request;
}

+ (id)requestForMethod:(NSString*)method
{
	return [StackMobRequest requestForMethod:method withHttpVerb:GET];
}	

+ (id)requestForMethod:(NSString*)method withHttpVerb:(SMHttpVerb)httpVerb
{
	return [StackMobRequest requestForMethod:method withArguments:nil withHttpVerb:httpVerb];
}

+ (id)userRequestForMethod:(NSString *)method withHttpVerb:(SMHttpVerb)httpVerb
{
	return [StackMobRequest userRequestForMethod:method withArguments:nil withHttpVerb:httpVerb];    
}

+ (id)requestForMethod:(NSString*)method withArguments:(NSDictionary*)arguments withHttpVerb:(SMHttpVerb)httpVerb
{
	StackMobRequest *request = [[[StackMobRequest alloc] init] autorelease];
    request.backingRequest = [[[StackMob stackmob] client]  requestWithResourcePath:method delegate:request];
    request.backingRequest.method = [StackMobRequest restKitVerbFromStackMob:httpVerb];
	if (arguments != nil)
    {
		[request setArguments:arguments];
	}
	return request;
}

+ (id)userRequestForMethod:(NSString*)method withArguments:(NSDictionary*)arguments withHttpVerb:(SMHttpVerb)httpVerb
{
	StackMobRequest *request = [[[StackMobRequest alloc] init] autorelease];
    request.userBased = YES;
    request.backingRequest = [[[StackMob stackmob] client]  requestWithResourcePath:method delegate:request];
    request.backingRequest.method = [StackMobRequest restKitVerbFromStackMob:httpVerb];
	if (arguments != nil)
    {
		[request setArguments:arguments];
	}
	return request;
}

+ (id)userRequestForMethod:(NSString *)method withQuery:(StackMobQuery *)query withHttpVerb:(SMHttpVerb)httpVerb
{
    StackMobRequest *request = [StackMobRequest userRequestForMethod:method withArguments:query.params withHttpVerb:httpVerb];
    [request setHeaders:query.headers];
    return request;
}

+ (id)requestForMethod:(NSString*)method withQuery:(StackMobQuery *)query withHttpVerb:(SMHttpVerb) httpVerb
{
    StackMobRequest *request = [StackMobRequest requestForMethod:method withArguments:[query params] withHttpVerb:httpVerb];
    [request setHeaders:query.headers];
    return request;
}


+ (id)requestForMethod:(NSString *)method withData:(NSData *)data
{
    StackMobRequest *request = [StackMobRequest request];
    request.method = method;
    request.httpMethod = POST;
    request.body = data;
    return request;
}

+ (id)pushRequestWithArguments:(NSDictionary*)arguments withHttpVerb:(SMHttpVerb) httpVerb {
	StackMobRequest* request = [StackMobPushRequest request];
	request.httpMethod = httpVerb;
	if (arguments != nil) {
		[request setArguments:arguments];
	}
	return request;
}

- (NSString *)getBaseURL {
    if(mIsSecure) {
        return [[[self backingRequest] URL] absoluteString];
    }
    return [[[self backingRequest] URL] absoluteString];
}

- (NSURL*)getURL
{
    // nil method is an invalid request
	if(!self.method) return nil;
    
    // build URL and add query string if necessary
    NSMutableArray *urlComponents = [NSMutableArray arrayWithCapacity:2];
    [urlComponents addObject:self.baseURL]; 
    
    if ((self.httpMethod == GET || self.httpMethod == DELETE) &&    
		[mArguments count] > 0) {
		[urlComponents addObject:[mArguments queryString]];
	}
    
    NSString *urlString = [urlComponents componentsJoinedByString:@"?"];
    SMLog(@"%@", urlString);
    
	return [NSURL URLWithString:urlString];
}

- (NSString *)getMethod 
{
    return [[self backingRequest] resourcePath];
}

- (void)setMethod:(NSString *)method
{
    [self backingRequest].resourcePath = method;
}

- (SMHttpVerb)getHTTPMethod 
{
    return [StackMobRequest stackMobVerbFromRestKit:[self backingRequest].method];
}

- (void)setHTTPMethod:(SMHttpVerb)httpMethod
{
    [self backingRequest].method = [StackMobRequest restKitVerbFromStackMob:httpMethod];
}
    

- (NSInteger)getStatusCode
{
	return [mHttpResponse statusCode];
}


- (id)init
{
	self = [super init];
    if(self){
        self.delegate = nil;
        self.result = nil;
        mArguments = [[NSMutableDictionary alloc] init];
        mHeaders = [[NSMutableDictionary alloc] init];
        mConnectionData = [[NSMutableData alloc] init];
        mResult = nil;
        session = [StackMobSession session];
    }
	return self;
}

#pragma mark -

- (void)setArguments:(NSDictionary*)arguments
{
	[mArguments setDictionary:arguments];
}

- (void)setHeaders:(NSDictionary *)headers {
    [mHeaders setDictionary:headers];
}

+ (NSData *)JsonifyNSDictionary:(NSMutableDictionary *)dict withErrorOutput:(NSError **)error {
    
    static id(^unsupportedClassSerializerBlock)(id) = ^id(id object) {
        if ( [object isKindOfClass:[NSData class]] ) {
            NSString* base64String = [(NSData*)object JSON];
            
            return base64String;
        }
        else if([object isKindOfClass:[SMFile class]]) {
            return [(SMFile *)object JSON];
        }
        else {
            return nil;
        }
    };
    
    NSData * json = [dict JSONDataWithOptions:JKSerializeOptionNone
        serializeUnsupportedClassesUsingBlock:unsupportedClassSerializerBlock
                                        error:error];
    return json;
}

- (NSString*)getAcceptHeaderForVersion:(NSNumber *)version
{
    return [NSString stringWithFormat:@"application/vnd.stackmob+json; version=%d",[version intValue]];
}

- (void)sendRequest
{
    _requestFinished = NO;
    SMLog(@"StackMob method: %@", self.method);
    SMLog(@"Request with url: %@", self.url);
    SMLog(@"Request with HTTP Method: %@", self.httpMethod);
    [[self backingRequest] send];
}

- (void)cancel
{
    [[self backingRequest] cancel];
}

- (NSString*) description {
    return [NSString stringWithFormat:@"%@: %@", [super description], self.url];
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response 
{ 
    SMLog(@"StackMobRequest %p: Received Request: %@", self, self.method)
    self.result = [[response bodyAsString] objectFromJSONString];
    [self callback]([response isSuccessful], self.result);
    _requestFinished = YES;
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
    SMLog(@"StackMobRequest %p: Connection failed! Error - %@ %@",
          self,
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    self.result = [NSDictionary dictionaryWithObjectsAndKeys:[error localizedDescription], @"statusDetails", nil];  
    [self callback](NO, self.result);
    _requestFinished = YES;  

}


+ (RKRequestMethod)restKitVerbFromStackMob:(SMHttpVerb)httpVerb
{
	switch (httpVerb) {
		case POST:
			return RKRequestMethodPOST;	
		case PUT:
			return RKRequestMethodPUT;
		case DELETE:
			return RKRequestMethodDELETE;	
		default:
			return RKRequestMethodGET;
	}
}

+ (SMHttpVerb)stackMobVerbFromRestKit:(RKRequestMethod)httpVerb
{
	switch (httpVerb) {
		case RKRequestMethodPOST:
			return POST;	
		case RKRequestMethodPUT:
			return PUT;
		case RKRequestMethodDELETE:
			return DELETE;	
		default:
			return GET;
	}
}


@end
