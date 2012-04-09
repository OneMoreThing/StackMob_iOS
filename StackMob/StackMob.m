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
#import "StackMobConfiguration.h"
#import "StackMobPushRequest.h"
#import "StackMobRequest.h"
#import "StackMobAdditions.h"
#import "StackMobClientData.h"
#import "StackMobHerokuRequest.h"
#import "StackMobBulkRequest.h"

@interface StackMob()

- (StackMobRequest *)destroy:(NSString *)path withArguments:(NSDictionary *)arguments andHeaders:(NSDictionary *)headers andCallback:(StackMobCallback)callback;

@end

#define ENVIRONMENTS [NSArray arrayWithObjects:@"production", @"development", nil]

@implementation StackMob

struct {
    unsigned int stackMobDidStartSession:1;
    unsigned int stackMobDidEndSession:1;
} delegateRespondsTo;

@synthesize session = _session;
@synthesize cookieStore = _cookieStore;
@synthesize client = _client;
@synthesize sessionDelegate = _sessionDelegate;

static StackMob *_sharedManager = nil;
static SMEnvironment environment;

+ (StackMob *)setApplication:(NSString *)apiKey secret:(NSString *)apiSecret appName:(NSString *)appName subDomain:(NSString *)subDomain userObjectName:(NSString *)userObjectName apiVersionNumber:(NSNumber *)apiVersion 
{
    return [StackMob setApplication:apiKey secret:apiSecret appName:appName subDomain:subDomain domain:SMDefaultDomain userObjectName:userObjectName apiVersionNumber:apiVersion];
}

+ (StackMob *)setApplication:(NSString *)apiKey secret:(NSString *)apiSecret appName:(NSString *)appName subDomain:(NSString *)subDomain domain:(NSString *)domain userObjectName:(NSString *)userObjectName apiVersionNumber:(NSNumber *)apiVersion
{
    if (_sharedManager == nil) {
        environment = SMEnvironmentProduction;
        _sharedManager = [[super allocWithZone:NULL] init];
        _sharedManager.client = [RKClient clientWithBaseURL:[NSString stringWithFormat:@"http://api.%@.%@", STACKMOB_APP_MOB, STACKMOB_APP_DOMAIN]];  
        _sharedManager.client.OAuth1ConsumerKey = STACKMOB_PUBLIC_KEY;
        _sharedManager.client.OAuth1ConsumerSecret = STACKMOB_PRIVATE_KEY;
        _sharedManager.client.authenticationType = RKRequestAuthenticationTypeOAuth1;
        [_sharedManager.client setValue:[NSString stringWithFormat:@"application/vnd.stackmob+json; version=%d", STACKMOB_API_VERSION] forHTTPHeaderField:@"Accept"];
        _sharedManager.session = [StackMobSession sessionForApplication:apiKey
                                                                 secret:apiSecret
                                                                appName:appName
                                                              subDomain:subDomain
                                                                 domain:domain
                                                         userObjectName:userObjectName
                                                       apiVersionNumber:apiVersion];
        _sharedManager.cookieStore = [[StackMobCookieStore alloc] initWithSession:_sharedManager.session];
    }
    return _sharedManager;
}

+ (StackMob *)stackmob {
    if (_sharedManager == nil) {
        [StackMob setApplication:STACKMOB_PUBLIC_KEY 
                          secret:STACKMOB_PRIVATE_KEY 
                         appName:STACKMOB_APP_NAME 
                       subDomain:STACKMOB_APP_MOB 
                  userObjectName:STACKMOB_USER_OBJECT_NAME 
                apiVersionNumber:STACKMOB_API_VERSION];
    }
    return _sharedManager;
}

#pragma mark - Session Methods

- (StackMobRequest *)startSession
{
    StackMobRequest *request = [StackMobRequest requestForMethod:@"startsession" withHttpVerb:POST];
    StackMob *this = self;
	return [request sendRequestWithCallback:^(BOOL success, id result) {
        if (delegateRespondsTo.stackMobDidStartSession) {
            [this.sessionDelegate stackMobDidStartSession];
        }  
    }];
}

- (StackMobRequest *)endSession{
    StackMobRequest *request = [StackMobRequest requestForMethod:@"endsession" withHttpVerb:POST];
    StackMob *this = self;
	return [request sendRequestWithCallback:^(BOOL success, id result) {
        if (delegateRespondsTo.stackMobDidEndSession) {
            [this.sessionDelegate stackMobDidEndSession];
        }                
    }];    
}

- (void)setSessionDelegate:(id)aSessionDelegate {
    if (self.sessionDelegate != aSessionDelegate) {
        [_sessionDelegate release];
        _sessionDelegate = aSessionDelegate;
        [_sessionDelegate retain];
        
        delegateRespondsTo.stackMobDidStartSession = [_sessionDelegate 
                                                      respondsToSelector:@selector(stackMobDidStartSession)];
        delegateRespondsTo.stackMobDidEndSession = [_sessionDelegate 
                                                    respondsToSelector:@selector(stackMobDidEndSession)];
        
        NSLog(@"delegate: %d %d", delegateRespondsTo.stackMobDidStartSession, delegateRespondsTo.stackMobDidEndSession);
    }
}

# pragma mark - User object Methods

- (StackMobRequest *)registerWithArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback
{
    StackMobRequest *request = [StackMobRequest requestForMethod:self.session.userObjectName
                                                   withArguments:arguments
                                                    withHttpVerb:POST]; 
    request.isSecure = YES;
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)loginWithArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback
{
    StackMobRequest *request = [StackMobRequest requestForMethod:[NSString stringWithFormat:@"%@/login", self.session.userObjectName]
                                                   withArguments:arguments
                                                    withHttpVerb:GET]; 
    request.isSecure = YES;
    
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)logoutWithCallback:(StackMobCallback)callback
{
    StackMobRequest *request = [StackMobRequest requestForMethod:[NSString stringWithFormat:@"%@/logout", self.session.userObjectName]
                                                   withArguments:[NSDictionary dictionary]
                                                    withHttpVerb:GET]; 
    request.isSecure = YES;
	return [request sendRequestWithCallback:callback];
    
}

- (StackMobRequest *)getUserInfowithArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback
{
    return [self get:self.session.userObjectName withArguments:arguments andCallback:callback];
}

- (StackMobRequest *)getUserInfowithQuery:(StackMobQuery *)query andCallback:(StackMobCallback)callback {
    return [self get:self.session.userObjectName withQuery:query andCallback:callback];
}

# pragma mark - Facebook methods
- (StackMobRequest *)loginWithFacebookToken:(NSString *)facebookToken andCallback:(StackMobCallback)callback
{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:facebookToken, @"fb_at", nil];
    StackMobRequest *request = [StackMobRequest userRequestForMethod:@"facebookLogin" withArguments:args withHttpVerb:GET];
    request.isSecure = YES;
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)registerWithFacebookToken:(NSString *)facebookToken username:(NSString *)username andCallback:(StackMobCallback)callback
{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:facebookToken, @"fb_at", username, @"username", nil];
    StackMobRequest *request = [StackMobRequest userRequestForMethod:@"createUserWithFacebook" withArguments:args withHttpVerb:GET];
    request.isSecure = YES;
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)linkUserWithFacebookToken:(NSString *)facebookToken withCallback:(StackMobCallback)callback
{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:facebookToken, @"fb_at", nil];
    StackMobRequest *request = [StackMobRequest userRequestForMethod:@"linkUserWithFacebook" withArguments:args withHttpVerb:GET];
    request.isSecure = YES;
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)postFacebookMessage:(NSString *)message withCallback:(StackMobCallback)callback
{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:message, @"message", nil];
    StackMobRequest *request = [StackMobRequest userRequestForMethod:@"postFacebookMessage" withArguments:args withHttpVerb:GET];
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)getFacebookUserInfoWithCallback:(StackMobCallback)callback
{
    return [self get:@"getFacebookUserInfo" withCallback:callback];
}

# pragma mark - Twitter methods

- (StackMobRequest *)registerWithTwitterToken:(NSString *)token secret:(NSString *)secret username:(NSString *)username andCallback:(StackMobCallback)callback
{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:token, @"tw_tk", secret, @"tw_ts", username, @"username", nil];
    StackMobRequest *request = [StackMobRequest userRequestForMethod:@"createUserWithTwitter" withArguments:args withHttpVerb:GET];
    request.isSecure = YES;
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)loginWithTwitterToken:(NSString *)token secret:(NSString *)secret andCallback:(StackMobCallback)callback
{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:token, @"tw_tk", secret, @"tw_ts", nil];
    StackMobRequest *request = [StackMobRequest userRequestForMethod:@"twitterLogin" withArguments:args withHttpVerb:GET];
    request.isSecure = YES;
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)linkUserWithTwitterToken:(NSString *)token secret:(NSString *)secret andCallback:(StackMobCallback)callback
{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:token, @"tw_tk", secret, @"tw_ts", nil];
    StackMobRequest *request = [StackMobRequest userRequestForMethod:@"linkUserWithTwitter" withArguments:args withHttpVerb:GET];
    request.isSecure = YES;
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)twitterStatusUpdate:(NSString *)message withCallback:(StackMobCallback)callback
{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:message, @"tw_st", nil];
    StackMobRequest *request = [StackMobRequest userRequestForMethod:@"twitterStatusUpdate" withArguments:args withHttpVerb:GET];
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)getTwitterInfoWithCallback:(StackMobCallback)callback
{
    return [self get:@"getTwitterUserInfo" withCallback:callback];
}


# pragma mark - PUSH Notifications

- (StackMobRequest *)registerForPushWithUser:(NSString *)userId token:(NSString *)token andCallback:(StackMobCallback)callback
{
    NSDictionary *tokenDict = [NSDictionary dictionaryWithObjectsAndKeys:token, @"token",
                               @"ios", @"type",
                               nil];
    
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:userId, @"userId",
                          tokenDict, @"token",
                          nil];
    
    StackMobPushRequest *pushRequest = [StackMobPushRequest requestForMethod:@"register_device_token_universal"];
    SMLog(@"args %@", body);
    [pushRequest setArguments:body];
	return [pushRequest sendRequestWithCallback:callback];
}

- (StackMobRequest *)sendPushBroadcastWithArguments:(NSDictionary *)args andCallback:(StackMobCallback)callback {
    //{"kvPairs":{"key1":"val1",...}}
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:args, @"kvPairs", nil];
    StackMobPushRequest *request = [StackMobPushRequest requestForMethod:@"push_broadcast_universal" withArguments:body];
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)sendPushToTokensWithArguments:(NSDictionary *)args withTokens:(NSArray *)tokens andCallback:(StackMobCallback)callback
{
    //{"payload":{"kvPairs":{"recipients":"asdf","alert":"asdfasdf"}},"tokens":[{"type":"iOS","token":"ASDF"}]}
    NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:args, @"kvPairs", nil];
    NSMutableArray * tokensArray = [NSMutableArray array];
    for(NSString * tkn in tokens) {
        NSDictionary * tknDict = [NSDictionary dictionaryWithObjectsAndKeys:tkn, @"token", @"ios", @"type", nil];
        [tokensArray addObject:tknDict];
    }
    
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:tokensArray, @"tokens", payload, @"payload", nil];
    StackMobPushRequest *request = [StackMobPushRequest requestForMethod:@"push_tokens_universal" withArguments:body];
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)sendPushToUsersWithArguments:(NSDictionary *)args withUserIds:(NSArray *)userIds andCallback:(StackMobCallback)callback
{
    //{kvPairs: {"asdas":"asdasd"}, "userIds":["user1", "user2"]}
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:args, @"kvPairs", userIds, @"userIds", nil];
    StackMobPushRequest *request = [StackMobPushRequest requestForMethod:@"push_users_universal" withArguments:body];
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)getPushTokensForUsers:(NSArray *)userIds andCallback:(StackMobCallback)callback
{
    //?userIds=user1,user2,user3
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:userIds, @"userIds", nil];
    StackMobPushRequest *request = [StackMobPushRequest requestForMethod:@"get_tokens_for_users_universal" withArguments:args withHttpVerb:GET];
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)deletePushToken:(NSString *)token andCallback:(StackMobCallback)callback
{
    //{"token":"asdasdASASasd", "type":"android|ios"}
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:token, @"token", @"ios", @"type", nil];
    StackMobPushRequest *request = [StackMobPushRequest requestForMethod:@"remove_token_universal" withArguments:body];
	return [request sendRequestWithCallback:callback];
}

# pragma mark - Heroku methods

- (StackMobRequest *)herokuGet:(NSString *)path withCallback:(StackMobCallback)callback
{
    StackMobHerokuRequest *request = [StackMobHerokuRequest requestForMethod:path
                                                               withArguments:NULL
                                                                withHttpVerb:GET];
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)herokuGet:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback
{
    StackMobHerokuRequest *request = [StackMobHerokuRequest requestForMethod:path
                                                               withArguments:arguments
                                                                withHttpVerb:GET];
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)herokuPost:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback
{
    StackMobHerokuRequest *request = [StackMobHerokuRequest requestForMethod:path
                                                               withArguments:arguments
                                                                withHttpVerb:POST];
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)herokuPut:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback
{
    StackMobHerokuRequest *request = [StackMobHerokuRequest requestForMethod:path
                                                               withArguments:arguments
                                                                withHttpVerb:PUT];
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)herokuDelete:(NSString *)path andCallback:(StackMobCallback)callback
{
    StackMobHerokuRequest *request = [StackMobHerokuRequest requestForMethod:path
                                                               withArguments:nil
                                                                withHttpVerb:DELETE];
	return [request sendRequestWithCallback:callback];
}

# pragma mark - CRUD methods

- (StackMobRequest *)get:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback{
    StackMobRequest *request = [StackMobRequest requestForMethod:path
                                                   withArguments:arguments
                                                    withHttpVerb:GET];
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)get:(NSString *)path withQuery:(StackMobQuery *)query andCallback:(StackMobCallback)callback {
    return [self get:path withArguments:[query params]  andCallback:callback];
}

- (StackMobRequest *)get:(NSString *)path withCallback:(StackMobCallback)callback
{
    StackMobRequest *request = [StackMobRequest requestForMethod:path
                                                   withArguments:NULL
                                                    withHttpVerb:GET];
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)post:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback
{
    StackMobRequest *request = [StackMobRequest requestForMethod:path
                                                   withArguments:arguments
                                                    withHttpVerb:POST];
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)post:(NSString *)path forUser:(NSString *)user withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback
{
    NSDictionary *modifiedArguments = [NSMutableDictionary dictionaryWithDictionary:arguments];
    [modifiedArguments setValue:user forKey:self.session.userObjectName];
    StackMobRequest *request = [StackMobRequest requestForMethod:[NSString stringWithFormat:@"%@/%@", self.session.userObjectName, path]
                                                   withArguments:modifiedArguments
                                                    withHttpVerb:POST];
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)post:(NSString *)path withBulkArguments:(NSArray *)arguments andCallback:(StackMobCallback)callback {
    StackMobBulkRequest *request = [StackMobBulkRequest requestForMethod:path withArguments:arguments];
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)post:(NSString *)path withId:(NSString *)primaryId andField:(NSString *)relField andArguments:(NSDictionary *)args andCallback:(StackMobCallback)callback {
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@/%@", path, primaryId, relField];
    return [self post:fullPath withArguments:args andCallback:callback];
}

- (StackMobRequest *)post:(NSString *)path withId:(NSString *)primaryId andField:(NSString *)relField andBulkArguments:(NSArray *)arguments andCallback:(StackMobCallback)callback {
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@/%@", path, primaryId, relField];
    return [self post:fullPath withBulkArguments:arguments andCallback:callback];
}

- (StackMobRequest *)put:(NSString *)path withId:(NSString *)objectId andArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback {
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", path, objectId];
    
    StackMobRequest *request = [StackMobRequest requestForMethod:fullPath withArguments:arguments withHttpVerb:PUT];
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)put:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback{
    StackMobRequest *request = [StackMobRequest requestForMethod:path
                                                   withArguments:arguments
                                                    withHttpVerb:PUT];
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)put:(NSString *)path withId:(id)primaryId andField:(NSString *)relField andArguments:(NSArray *)args andCallback:(StackMobCallback)callback {
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@/%@", path, primaryId, relField];
    StackMobBulkRequest *request = [StackMobBulkRequest requestForMethod:fullPath withArguments:args];
    request.httpMethod = PUT;
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)destroy:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback{
    return [self destroy:path withArguments:arguments andHeaders:[NSDictionary dictionary] andCallback:callback];
}

- (StackMobRequest *)destroy:(NSString *)path withArguments:(NSDictionary *)arguments andHeaders:(NSDictionary *)headers andCallback:(StackMobCallback)callback {
    StackMobRequest *request = [StackMobRequest requestForMethod:path
                                                   withArguments:arguments
                                                    withHttpVerb:DELETE];
    [request setHeaders:headers];
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)removeIds:(NSArray *)removeIds forSchema:(NSString *)schema andId:(NSString *)primaryId andField:(NSString *)relField withCallback:(StackMobCallback)callback {
    return [self removeIds:removeIds forSchema:schema andId:primaryId andField:relField shouldCascade:NO withCallback:callback];
}

- (StackMobRequest *)removeIds:(NSArray *)removeIds forSchema:(NSString *)schema andId:(NSString *)primaryId andField:(NSString *)relField shouldCascade:(BOOL)isCascade withCallback:(StackMobCallback)callback {
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@/%@/%@", schema, primaryId, relField, [removeIds componentsJoinedByString:@","]];
    NSDictionary *headers;
    if (isCascade == YES) {
        headers = [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"X-StackMob-CascadeDelete", nil];
    } else {
        headers = [NSDictionary dictionary];
    }
    return [self destroy:fullPath 
           withArguments:[NSDictionary dictionary] 
              andHeaders:headers 
             andCallback:callback];
    
}


- (StackMobRequest *)removeId:(NSString *)removeId forSchema:(NSString *)schema andId:(NSString *)primaryId andField:(NSString *)relField withCallback:(StackMobCallback)callback {
    return [self removeId:removeId 
                forSchema:schema 
                    andId:primaryId 
                 andField:relField 
            shouldCascade:NO 
             withCallback:callback];
}

- (StackMobRequest *)removeId:(NSString *)removeId forSchema:(NSString *)schema andId:(NSString *)primaryId andField:(NSString *)relField shouldCascade:(BOOL)isCascade withCallback:(StackMobCallback)callback {
    return [self removeIds:[NSArray arrayWithObject:removeId] 
                 forSchema:schema 
                     andId:primaryId 
                  andField:relField 
             shouldCascade:isCascade 
              withCallback:callback];
    
}

# pragma mark - Forgot/Reset password

- (StackMobRequest *)forgotPasswordByUser:(NSString *)username andCallback:(StackMobCallback)callback
{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", nil];
    StackMobRequest *request = [StackMobRequest userRequestForMethod:@"forgotPassword" withArguments:args withHttpVerb:POST];
    request.isSecure = YES;
	return [request sendRequestWithCallback:callback];
}

- (StackMobRequest *)resetPasswordWithOldPassword:(NSString*)oldPassword newPassword:(NSString*)newPassword andCallback:(StackMobCallback)callback
{
    NSDictionary *oldPWDict = [NSDictionary dictionaryWithObjectsAndKeys:oldPassword, @"password", nil];
    NSDictionary *newPWDict = [NSDictionary dictionaryWithObjectsAndKeys:newPassword, @"password", nil];
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:oldPWDict, @"old", newPWDict, @"new", nil];
    StackMobRequest *request = [StackMobRequest userRequestForMethod:@"resetPassword" withArguments:body withHttpVerb:POST];
    request.isSecure = YES;
	return [request sendRequestWithCallback:callback];
}


# pragma mark - Private methods


# pragma mark - Singleton Conformity

static StackMob *sharedSession = nil;

+ (StackMob *)sharedManager
{
    if (sharedSession == nil) {
        sharedSession = [[super allocWithZone:NULL] init];
    }
    return sharedSession;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedManager] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (oneway void)release
{
    // do nothing
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (id)autorelease
{
    return self;
}
@end




