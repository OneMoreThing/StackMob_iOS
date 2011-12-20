//
//  AppDelegate.m
//  ReskitDemoApp
//
//  Created by Ryan Connelly on 11/3/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "StackMob/STMRestKitConfiguration.h"
#import "UserModel.h"
#import "StackMob/StackMob.h"

#import "StackMob/STMRestKitDataProvider.h"
#import "StackMob/STMResponseError.h"
#import "StackMob/STMObjectMappingProvider.h"
#import "StackMob/STMClient.h"
#import "StackMob/STMObjectRouter.h"
#import "StackMob/STMObjectMapping.h"

@interface AppDelegate()
- (STMRestKitConfiguration *) newConfig;
@end

@implementation AppDelegate
@synthesize window = _window;

- (STMRestKitConfiguration *) newConfig
{
    STMRestKitConfiguration *config = [STMRestKitConfiguration configuration];
    NSArray *mappings = [STMObjectMapping defaultMappingsForClasses:[UserModel class], nil];
    [config.mappingProvider registerObjectMappings:mappings];
    return config;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    STMRestKitConfiguration *config = [self newConfig];
    // Override point for customization after application launch.
    id<STMDataProvider> dataProvider = [STMRestkitDataProvider dataProviderWithConfiguration:config];
    
    [StackMob setApplication:STACKMOB_PUBLIC_KEY
                      secret:STACKMOB_PRIVATE_KEY
                     appName:STACKMOB_APP_NAME
                   subDomain:STACKMOB_APP_SUBDOMAIN
              userObjectName:STACKMOB_USER_OBJECT_NAME
            apiVersionNumber:[NSNumber numberWithInt:STACKMOB_API_VERSION]
                dataProvider:dataProvider];
    
    [[[StackMob stackmob] dataProvider] prepare];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


@end
