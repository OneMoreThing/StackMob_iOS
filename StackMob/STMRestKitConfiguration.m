//
//  RestKitConfiguration.m
//  StackMobiOS
//
//  Created by Ryan Connelly on 10/9/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "STMRestKitConfiguration.h"
#import "STMResponseError.h"
#import "STMObjectMappingProvider.h"
#import "STMObjectRouter.h"

@implementation STMRestKitConfiguration
@synthesize mappingProvider;
@synthesize client;
@synthesize router;
@synthesize inferMappingsFromObjectTypes;

- (id) init
{
    self = [super init];
    
    if(self)
    {
        router = [STMObjectRouter new];
        mappingProvider = [[STMObjectMappingProvider alloc] initWithRouter:router];
    }
    
    return self;
}

+ (STMRestKitConfiguration *) configuration
{
    return [[[self alloc] init] autorelease];
}
@end
