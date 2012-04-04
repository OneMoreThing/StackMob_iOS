// Copyright 2011 StackMob, Inc
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <UIKit/UIKit.h>
#import "../StackMob/External/RestKit/Vendor/cocoa-oauth/NSData+Base64.h"
#import "StackMobLoginTest.h"

#define USER_NAME @"USER_NAME_HERE"
#define USER_PASSWORD @"USER_PASSWORD_HERE"

//#import "application_headers" as required

@implementation StackMobLoginTest
- (void)setUp {
    [super setUp];
}

- (void)testSetCookieLoginLogout {
    NSMutableDictionary *loginRequest = [[NSMutableDictionary alloc] init];
    [loginRequest setValue:USER_NAME forKey:@"username"];
    [loginRequest setValue:USER_PASSWORD forKey:@"password"];
    [[StackMob stackmob] loginWithArguments:loginRequest andCallback:^(BOOL success, id result) {
        STAssertTrue(success == YES, @"login failed");
        STAssertTrue([[[[StackMob stackmob] cookieStore] cookieHeader] length] != 0, @"Auth cookie was not set");
    }];
    
    [[StackMob stackmob] logoutWithCallback:^(BOOL success, id result) {
        STAssertTrue(success == YES, @"logout failed");
    }];
}


@end