//
//  StackMobCon.m
//  StackMobiOS
//
//  Created by Ryan Connelly on 10/9/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//


#import "StackMobConfiguration.h"

@implementation StackMobConfiguration
@synthesize appName;
@synthesize apiVersion;
@synthesize domain;
@synthesize publicKey;
@synthesize subdomain;
@synthesize privateKey;
@synthesize userObjectName;
@synthesize dataProvider;

- (void)dealloc 
{
    [appName release];
    [apiVersion release];
    [domain release];
    [publicKey release];
    [subdomain release];
    [privateKey release];
    [userObjectName release];
    [dataProvider release];
    [super dealloc];
}

@end