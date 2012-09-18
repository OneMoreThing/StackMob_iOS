//
//  StackMobOAuth2Test.h
//  StackMobiOS
//
//  Created by Matt Vaznaian on 7/3/12.
//  Copyright (c) 2012 StackMob, Inc. All rights reserved.
//

// TO TEST: create a schema oauth2test with create permissions set to any logged in user with OAuth2 and read, update and delete permissions set to
// Object owner logged in with OAuth2.
// Also make sure your user schema is open to create and delete from.

#import <SenTestingKit/SenTestingKit.h>
#import "StackMob.h"
#import "StackMobTestUtils.h"
#import "StackMobTestCommon.h"

@interface StackMobOAuth2Test : SenTestCase

- (void)setUp;
- (void)tearDown;
- (void)assertNotNSError:(id)obj;
- (void)createUser;
- (void)deleteUser;
- (void)testLoginAndLogoutWithOAuth2;
- (void)changeOAuthVersion:(int)oAuthVersion;
- (void)testErrorStatusCodeAndDescription;
@end
