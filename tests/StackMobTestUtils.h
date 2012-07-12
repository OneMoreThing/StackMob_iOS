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

#import <Foundation/Foundation.h>
#import "StackMob.h"

#define USER_NAME @"USER_NAME"
#define USER_PASSWORD @"USER_PASSWORD"
#define FB_TOKEN @"FB_TOKEN"
#define TWITTER_TOKEN @"TWITTER_TOKEN"
#define TWITTER_SECRET @"TWITTER_SECRET"

extern NSString * const kAPIKey;
extern NSString * const kAPISecret;
extern NSString * const kSubDomain;
extern NSString * const kAppName;
extern NSInteger  const kVersion;


@interface StackMobTestUtils : NSObject
+ (void)runRunLoop:(NSRunLoop *)runLoop untilRequestFinished:(StackMobRequest *)request;
+ (id)runDefaultRunLoopAndGetDictionaryResultFromRequest:(StackMobRequest *)request;

@end
