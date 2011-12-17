//
//  RestKitProviderTests.h
//  StackMobiOS
//
//  Created by Ryan Connelly on 10/10/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

//  Application unit tests contain unit test code that must be injected into an application to run correctly.
//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

#import <SenTestingKit/SenTestingKit.h>
#import "StackMobTestCommon.h"

@class STMRestKitConfiguration;
@interface RestKitProviderTests : StackMobTestCommon

@property (nonatomic, assign) StackMobSession *session;
- (STMRestKitConfiguration *) config;
@end
