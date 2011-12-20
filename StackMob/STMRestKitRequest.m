//
//  RestkitRequest.m
//  StackMobiOS
//
//  Created by Ryan Connelly on 10/9/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "StackMob.h"
#import "STMRestKitRequest.h"
#import "StackMobRequest.h"
#import "StackMobSession.h"
#import "STMRestKitObjectLoaderDelegate.h"
#import "STMRestKitObjectLoader.h"
#import "STMObjectRouter.h"
#import "STMRestKitObjectManager.h"
#import "STMRestKitDataProvider.h"
#import "STMRestKitConfiguration.h"

@interface STMRestKitRequest (Private)
- (RKRequestMethod) requestMethodFromString:(NSString *)verb;
- (STMRestKitObjectLoaderDelegate *) newLoaderDelegate:(id<SMRequestDelegate>)requestDelegate;
- (NSString *)baseUrlWithSession:(StackMobSession *)sess;
+ (NSString *) expandRelativePath:(NSString *)path isUserBased:(BOOL)isUserBased;
@end

@implementation STMRestKitRequest
@synthesize objectManager = _objectManager;
@synthesize authClient = _authClient;
@synthesize loader;
@synthesize loaderDelegate;

#pragma mark - RKOAuthClientDelegate

- (void)OAuthClient:(RKOAuthClient *)client didAcquireAccessToken:(NSString *)token
{
    
}

- (void)OAuthClient:(RKOAuthClient *)client didFailWithInvalidGrantError:(NSError *)error
{
    
}

+ (id)requestForMethod:(NSString*)method withArguments:(NSDictionary*)arguments withHttpVerb:(SMHttpVerb) httpVerb
{
    return nil;
}

+ (id)userRequestForMethod:(NSString*)method withArguments:(NSDictionary*)arguments withHttpVerb:(SMHttpVerb)httpVerb
{
    return nil;
}

/*
 * Create a request for an iOS PUSH notification
 @param arguments a dictionary of arguments including :alert, :badge and :sound
 */
+ (id)pushRequestWithArguments:(NSDictionary*)arguments withHttpVerb:(SMHttpVerb) httpVerb
{
    //[self respondsToSelector:@selector(_cmd)];
    return nil;
}

# pragma mark - Initialization

+ (id)request	
{
    STMRestKitRequest *request = [[[STMRestKitRequest alloc] init] autorelease];
    return request;
}

+ (id)userRequest
{
    StackMobRequest *request = [self request];
    request.userBased = YES;
    return request;
}

/* Returns the full url based on a path */
+ (NSString *) expandRelativePath:(NSString *)path isUserBased:(BOOL)isUserBased
{
    StackMobSession *sess = [[StackMob stackmob] session];
    NSString *fullRelativePath = [[NSURL URLWithString:sess.apiURL] relativePath];    
    if(isUserBased)
    {
        fullRelativePath = [fullRelativePath stringByAppendingFormat:@"/%@",sess.userObjectName];
    }
    fullRelativePath = [fullRelativePath stringByAppendingFormat:@"/%@",path];
    return fullRelativePath;
}

+ (id)requestForMethod:(NSString*)method
{
	return [self requestForMethod:method withHttpVerb:GET];
}	

+ (id)requestForMethod:(NSString*)method withHttpVerb:(SMHttpVerb)httpVerb
{
	return [self requestForMethod:method withObject:nil withHttpVerb:httpVerb];
}

+ (id)userRequestForMethod:(NSString *)method withHttpVerb:(SMHttpVerb)httpVerb
{
	return [self userRequestForMethod:method withObject:nil withHttpVerb:httpVerb];    
}

+ (RKRequestMethod) requestMethodFromHttpVerb:(SMHttpVerb)verb
{
    switch (verb) {
        case GET:
            return RKRequestMethodGET;
            break;
        case POST:
            return RKRequestMethodPOST;
        case PUT:
            return RKRequestMethodPUT;
        case DELETE:
            return RKRequestMethodDELETE;
        default:
            return RKRequestMethodGET;
            break;
    }
}

+ (id)requestForMethod:(NSString*)method withObject:(id)object withHttpVerb:(SMHttpVerb)httpVerb
{
    STMRestKitRequest *request = [STMRestKitRequest request];
    request.method = method;
    if(object)
    {
        [request setObject:object];
    }
    else // infer object from path
    {
        STMRestkitDataProvider *provider = [StackMob stackmob].dataProvider;
        STMObjectRouter *router = provider.restKitConfiguration.router;
        NSString *fullPath = [self expandRelativePath:method isUserBased:NO];
        Class objectClass = [router classByResourcePath:fullPath forHttpVerb:[self requestMethodFromHttpVerb:httpVerb]];
        [request setObject:[[[objectClass alloc] init] autorelease]];
    }
    request.httpMethod = [self stringFromHttpVerb:httpVerb];
    return request;
}

+ (id)userRequestForMethod:(NSString*)method withObject:(id)object withHttpVerb:(SMHttpVerb)httpVerb
{
    STMRestKitRequest *request = [STMRestKitRequest request];
    request.userBased = YES;
    request.method = method;
    if(object)
    {
        [request setObject:object];
    }
    else
    {
        STMRestkitDataProvider *provider = [StackMob stackmob].dataProvider;
        NSString *fullPath = [self expandRelativePath:method isUserBased:YES];
        RKObjectMapping *mapping = [provider.restKitConfiguration.mappingProvider objectMappingForKeyPath:fullPath];
        [request setObject:[[[mapping.objectClass alloc] init] autorelease]];
    }
    return request;
}

+ (id)requestForMethod:(NSString *)method withData:(NSData *)data{
    /*StackMobRequest *request = [self request];
     request.method = method;
     request.httpMethod = [self stringFromHttpVerb:POST];
     request.body = data;
     return request;
     */
    return nil;
}

- (NSString *)baseUrlWithSession:(StackMobSession *)sess
{
    NSString *protocol = (self.isSecure) ? @"https" : @"http";
    NSString *url = [NSString stringWithFormat:@"%@://%@.%@", protocol, sess.subDomain, sess.domain];
    return url;
}

- (id)init
{
	self = [super init];
    if(self){
        
        NSString *baseUrl = [self baseUrlWithSession:session];
        _objectManager = [[STMRestKitObjectManager objectManagerWithBaseURL:baseUrl] retain];
        _objectManager.client.baseURL = [NSString stringWithFormat:@"%@",baseUrl];
        _objectManager.client.OAuth1ConsumerKey =session.apiKey;
        _objectManager.client.OAuth1ConsumerSecret = session.apiSecret;
        //_objectManager.client.OAuth1AccessToken = @"YOUR ACCESS TOKEN";
        //_objectManager.client.OAuth1AccessTokenSecret = @"YOUR ACCESS TOKEN SECRET";
        _objectManager.client.authenticationType = RKRequestAuthenticationTypeOAuth1;
        _objectManager.serializationMIMEType = RKMIMETypeJSON;
    }
    
    
	return self;
}

- (NSInteger) getStatusCode
{
    return [[loader response] statusCode];
}

#pragma mark -

- (RKRequestMethod) requestMethodFromString:(NSString *)verb
{
    if([verb isEqualToString:@"POST"])
    {
        return RKRequestMethodPOST;
    }
    else if([verb isEqualToString:@"GET"])
    {
        return RKRequestMethodGET;
    }
    else if([verb isEqualToString:@"DELETE"])
    {
        return RKRequestMethodDELETE;
    }
    else if([verb isEqualToString:@"PUT"])
    {
        return RKRequestMethodPUT;
    }
    else
    {
        return RKRequestMethodGET;
    }
}

- (STMRestKitObjectLoaderDelegate *) newLoaderDelegate:(id<SMRequestDelegate>)requestDelegate
{
    return [[STMRestKitObjectLoaderDelegate alloc] initWithRequestDelegate:requestDelegate andRequest:self];
}

- (void) onRequestComplete
{
    _requestFinished = YES;
}

- (void)sendRequest
{
	_requestFinished = NO;
    //RKRequestMethod
    SMLogVerbose(@"RestKit method: %@", self.method);
    SMLogVerbose(@"Request Request with url: %@", self.url);
    SMLogVerbose(@"Request Request with HTTP Method: %@", self.httpMethod);
    SMLog(@"httpMethod %@", [self httpMethod]);
    
    self.loaderDelegate = [[self newLoaderDelegate:self.delegate] autorelease];
    RKRequestMethod method = [self requestMethodFromString:self.httpMethod];
    [self.objectManager sendObject:mObject delegate:loaderDelegate block:^(RKObjectLoader* l) {
        l.method = method;
        l.targetObject = nil;
        [[l additionalHTTPHeaders] setValue:@"gzip" forKey:@"Accept-Encoding"];
        [[l additionalHTTPHeaders] setValue:@"deflate" forKey:@"Accept-Encoding"];
    }];
}

- (void)cancel
{
	//[self.connection cancel];
	//self.connection = nil;
}

- (id) sendSynchronousRequestProvidingError:(NSError**)error {    
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id) sendSynchronousRequest {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void) dealloc
{
    [loaderDelegate release];
    [_authClient release];
    [_objectManager release];
    [super dealloc];
}

@end
