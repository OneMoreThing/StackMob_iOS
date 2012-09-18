//
//  StackMobOAuth2Test.m
//  StackMobiOS
//
//  Created by Matt Vaznaian on 7/3/12.
//  Copyright (c) 2012 StackMob, Inc. All rights reserved.
//


#import "StackMobOAuth2Test.h"

@implementation StackMobOAuth2Test

- (void)setUp
{
    [StackMob setApplication:OAuth2 key:kAPIKey secret:kAPISecret appName:kAppName subDomain:@"mob1" userObjectName:@"user" apiVersionNumber:[NSNumber numberWithInt:kVersion]];
    [self createUser];
}

- (void)tearDown
{
    [self deleteUser];
}

- (void)assertNotNSError:(id)obj
{
    if([obj class] == [NSError class]) STFail(@"object %@ is an error", obj);
}

- (void)changeOAuthVersion:(int)oAuthVersion
{
    [[[StackMob stackmob] session] setOauthVersion:oAuthVersion];
}

- (void)createUser
{
    NSDictionary *createArgs = [NSDictionary dictionaryWithObjectsAndKeys:USER_NAME, @"username", USER_PASSWORD, @"password", nil];
    StackMobRequest *createRequest = [[StackMob stackmob] registerWithArguments:createArgs andCallback:^(BOOL success, id result) {
        STAssertTrue(success, @"user not created");
    }];
    
    [StackMobTestUtils runRunLoop:[NSRunLoop currentRunLoop] untilRequestFinished:createRequest];
}

- (void)deleteUser
{
    NSDictionary *destroyArgs = [NSDictionary dictionaryWithObjectsAndKeys:USER_NAME, @"username", nil];
    StackMobRequest *deleteRequest = [[StackMob stackmob] destroy:@"user" withArguments:destroyArgs andCallback:^(BOOL success, id result) {
        STAssertTrue(success, @"object not deleted");
    }];
    
    [StackMobTestUtils runRunLoop:[NSRunLoop currentRunLoop] untilRequestFinished:deleteRequest];
}

- (void)testLoginAndLogoutWithOAuth2
{
    [[[StackMob stackmob] session] setOauthVersion:OAuth2];
    
    SMLog(@"oauthversion is %d", [[[StackMob stackmob] session] oauthVersion]);
    STAssertTrue([[[StackMob stackmob] session] oauthVersion] == 2, @"oauth version not correct");
    
    NSDictionary *userArgs = [NSDictionary dictionaryWithObjectsAndKeys:USER_NAME, @"username", USER_PASSWORD, @"password", nil];
    
    
    StackMobRequest *loginRequest = [[StackMob stackmob] loginWithArguments:userArgs andCallback:^(BOOL success, id result) {
        if (!success) {
            SMLog(@"you did not login correctly");
        }
        SMLog(@"result from login is %@", result);
        STAssertTrue([[StackMob stackmob] isLoggedIn], @"You are not logged in");
        STAssertTrue([[[StackMob stackmob] loggedInUser] isEqualToString:USER_NAME], @"user is not logged in");
        STAssertTrue([[[StackMob stackmob] session] oauthVersion] == 2, @"oauth version not correct");
        
        // make sure all oauth2 keys have been set
        STAssertTrue([[[StackMob stackmob] session] oauth2Key] != nil, @"OAuth2 key should be not be nil");
        STAssertTrue([[[StackMob stackmob] session] oauth2Token] != nil, @"OAuth2 token should not be be nil");
        
        NSDate *expDate = [[[StackMob stackmob] session] oauth2TokenExpiration];
        
        STAssertTrue([[expDate laterDate:[NSDate date]] isEqualToDate:expDate], @"OAuth2 expiration should be a later date than now");
        NSString *apiKey = [[[StackMob stackmob] session] apiKey];
        
        NSString *tokenFromDefaults = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@.token", apiKey]];
        STAssertTrue(tokenFromDefaults != nil, @"OAuth2 token in defaults should be not be nil");
        
        NSDate *dateFromDefaults = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@.token.expiration", apiKey]];
        STAssertTrue([[dateFromDefaults laterDate:[NSDate date]] isEqualToDate:dateFromDefaults], @"OAuth2 token in defaults should not be be nil");
    }];
    
    [StackMobTestUtils runRunLoop:[NSRunLoop currentRunLoop] untilRequestFinished:loginRequest];
    
    NSDictionary *createArgs = [NSDictionary dictionaryWithObjectsAndKeys:@"cool", @"name", @"cool", @"oauth2test_id", nil];
    StackMobRequest *createRequest = [[StackMob stackmob] post:@"oauth2test" withArguments:createArgs andCallback:^(BOOL success, id result) {
        SMLog(@"result from create is %@", result);
        STAssertTrue(success, @"object not created");
        
    }];
    
    [StackMobTestUtils runRunLoop:[NSRunLoop currentRunLoop] untilRequestFinished:createRequest];
    
    StackMobRequest *readRequest = [[StackMob stackmob] get:@"oauth2test/cool" withCallback:^(BOOL success, id result) {
        SMLog(@"result from read is %@", result);
        STAssertTrue(success, @"object not read");
    }];
    
    [StackMobTestUtils runRunLoop:[NSRunLoop currentRunLoop] untilRequestFinished:readRequest];
    
    
    NSDictionary *destroyArgs = [NSDictionary dictionaryWithObjectsAndKeys:@"cool", @"oauth2test_id", nil];
    StackMobRequest *deleteRequest = [[StackMob stackmob] destroy:@"oauth2test" withArguments:destroyArgs andCallback:^(BOOL success, id result) {
        SMLog(@"deleted object with result %@", result);
        STAssertTrue(success, @"object not deleted");
    }];
    
    [StackMobTestUtils runRunLoop:[NSRunLoop currentRunLoop] untilRequestFinished:deleteRequest];
    
    //test logout
    StackMobRequest *logoutRequest = [[StackMob stackmob] logoutWithCallback:^(BOOL success, id result) {
        STAssertTrue(success, @"did not logout successfully");
        STAssertTrue([[StackMob stackmob] isLoggedOut], @"You are still logged in");
        
        // make sure all oauth2 associated keys have been cleared
        STAssertTrue([[[StackMob stackmob] session] oauth2Key] == nil, @"OAuth2 key should be nil");
        STAssertTrue([[[StackMob stackmob] session] oauth2Token] == nil, @"OAuth2 token should be nil");
        
        NSDate *expDate = [[[StackMob stackmob] session] oauth2TokenExpiration];
        
        STAssertTrue(![[expDate laterDate:[NSDate date]] isEqualToDate:expDate], @"OAuth2 expiration should be an earlier date than now");
        NSString *apiKey = [[[StackMob stackmob] session] apiKey];
        
        NSString *tokenFromDefaults = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@.token", apiKey]];
        STAssertTrue(tokenFromDefaults == nil, @"OAuth2 token in defaults should be nil");
        
        NSDate *dateFromDefaults = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@.token.expiration", apiKey]];
        STAssertTrue(![[dateFromDefaults laterDate:[NSDate date]] isEqualToDate:dateFromDefaults], @"OAuth2 token in defaults should be nil");
    }];
    
    [StackMobTestUtils runRunLoop:[NSRunLoop currentRunLoop] untilRequestFinished:logoutRequest];

    //attempt to create, should fail
    NSDictionary *createArgs2 = [NSDictionary dictionaryWithObjectsAndKeys:@"cool", @"name", @"cool", @"oauth2test_id", nil];
    StackMobRequest *createRequest2 = [[StackMob stackmob] post:@"oauth2test" withArguments:createArgs2 andCallback:^(BOOL success, id result) {
        SMLog(@"result from create is %@", result);
        STAssertTrue(!success, @"should not have been able to create");
        
    }];
    
    [StackMobTestUtils runRunLoop:[NSRunLoop currentRunLoop] untilRequestFinished:createRequest2];
     
}

- (void)testErrorStatusCodeAndDescription
{
    [[[StackMob stackmob] session] setOauthVersion:OAuth2];
    
    SMLog(@"oauthversion is %d", [[[StackMob stackmob] session] oauthVersion]);
    STAssertTrue([[[StackMob stackmob] session] oauthVersion] == 2, @"oauth version not correct");
    
    NSDictionary *userArgs = [NSDictionary dictionaryWithObjectsAndKeys:USER_NAME, @"username", USER_PASSWORD, @"password", nil];
    
    
    StackMobRequest *loginRequest = [[StackMob stackmob] loginWithArguments:userArgs andCallback:^(BOOL success, id result) {
        if (!success) {
            SMLog(@"you did not login correctly");
        }
        SMLog(@"result from login is %@", result);
        STAssertTrue([[StackMob stackmob] isLoggedIn], @"You are not logged in");
        STAssertTrue([[[StackMob stackmob] loggedInUser] isEqualToString:USER_NAME], @"user is not logged in");
        STAssertTrue([[[StackMob stackmob] session] oauthVersion] == 2, @"oauth version not correct");
    }];
    
    [StackMobTestUtils runRunLoop:[NSRunLoop currentRunLoop] untilRequestFinished:loginRequest];
    
    StackMobRequest *request = [[StackMob stackmob] get:@"nonexistentschema" withCallback:^(BOOL success, id result) {
        if (!success) {
            NSError *theError = (NSError *)result;
            STAssertTrue([theError code] == 400, @"There should be a proper failure code");
            STAssertTrue([[theError userInfo] objectForKey:NSLocalizedDescriptionKey] != nil, @"There should be a failure reason when using oauth2");
        }
        else {
            STFail(@"Should not succeed");
        }
    }];
    [StackMobTestUtils runRunLoop:[NSRunLoop currentRunLoop] untilRequestFinished:request];
}

@end
