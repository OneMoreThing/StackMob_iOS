//
//  AppDelegate.h
//  ReskitDemoApp
//
//  Created by Ryan Connelly on 11/3/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define STACKMOB_PUBLIC_KEY @"9e065aef-076e-46e8-b456-554e283edb1d"
#define STACKMOB_PRIVATE_KEY @"bee36ca7-193a-40ed-8be7-13d2bbce7f1a"
#define STACKMOB_APP_NAME @"restkitdemoapp"
#define STACKMOB_APP_SUBDOMAIN @"nomadapps"
#define STACKMOB_APP_DOMAIN @"mob1.stackmob.com"
#define STACKMOB_USER_OBJECT_NAME @"user"
#define STACKMOB_API_VERSION 0

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
