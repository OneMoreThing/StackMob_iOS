//
//  RestKitProviderTests.m
//  StackMobiOS
//
//  Created by Ryan Connelly on 10/10/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "RestKitProviderTests.h"
#import "TestConstants.h"
#import "StackMob.h"
#import "RestKitDataProvider.h"
#import "UserResponseData.h"
#import "RestKitConfiguration.h"
//#import "RestKit/RestKit.h"
#import <UIKit/UIKit.h>
//#import "application_headers" as required

@implementation RestKitProviderTests
@synthesize session;

// All code under test is in the iOS Application
- (void)testUserPost
{
    NSLog(@"IN TEST POST");
       
    UserResponseData *userData = [[UserResponseData new] autorelease];
    
    userData.firstname = @"Ty";
    userData.lastname = @"Amell";
    userData.email = @"ty@stackmob.com";
	
    StackMobRequest *request = [[StackMob stackmob] post:@"user" withObject:userData andCallback:^(BOOL success, id result){
        if(success){
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            UserResponseData *userResponse = result;
            [info setObject:userResponse.firstname forKey:@"firstname"];
            [info setObject:userResponse.lastname forKey:@"lastname"];
            [info setObject:userResponse.email forKey:@"email"];
            
            NSLog(@"testPost result was: %@", info);
            
            STAssertNotNil(result, @"Returned value for POST should not be nil.");
            STAssertEqualObjects(userResponse.firstname, userData.firstname, @"first name does not match");
            STAssertEqualObjects(userResponse.email, userData.email, @"emails do not match.");
            STAssertEqualObjects(userResponse.lastname, userData.lastname, @"lastname does not match.");
            STAssertNotNil(userResponse.lastmoddate, @"lastmoddate should not be nil.");
            STAssertNotNil(userResponse.lastmoddate, @"createddate should not be nil.");            
        }
        else{
            STFail(@"creating a user failed");
        }
    }];
    
	//we need to loop until the request comes back, its just a test its OK
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	do {
		NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
		[runLoop acceptInputForMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
		[loopPool drain];
	} while(![request finished]);
	
	NSDictionary *result = [request result];
    NSLog(@"result %@", result);
}

- (void) setUp
{
    NSLog(@"In setup");
	if (!session) 
	{
        [StackMob setSharedManager:nil];
        RestkitDataProvider *provider = [RestkitDataProvider new];
        provider.restKitConfiguration = [self config];
        StackMob *stackMob = [StackMob setApplication:kAPIKey secret:kAPISecret appName:kAppName subDomain:kSubDomain userObjectName:@"user" apiVersionNumber:[NSNumber numberWithInt:kVersion]
                                         dataProvider:[provider autorelease]];
        
        self.session = [stackMob session];
		NSLog(@"Created new session");
	}
}

- (RestKitConfiguration *) config
{
    RestKitConfiguration *c = [RestKitConfiguration new];
    RKObjectRouter *r = [[RKObjectRouter new] autorelease];
    //c.inferMappingsFromObjectTypes = YES;
    [r routeClass:[UserResponseData class] toResourcePath:@"/user" forMethod:RKRequestMethodPOST];
    
    RKObjectMappingProvider *provider = [[RKObjectMappingProvider new] autorelease];
    
    
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[UserResponseData class] block:^(RKObjectMapping *m){
        [m mapAttributes:@"firstname",@"lastname",@"email", @"lastmoddate",@"username",@"createddate",nil]; 
    }];
                               
    // No "wrapped" namesapce objects
    [provider setMapping:mapping forKeyPath:@""];
    RKObjectMapping *inverseMapping = [mapping inverseMapping];
    [provider setSerializationMapping:inverseMapping forClass:[UserResponseData class]];
    
    c.router = r;
    c.mappingProvider = provider;
    
    return [c autorelease];
}


- (RKObjectMappingProvider *) mappingProvider
{
    return nil;
}

@end
