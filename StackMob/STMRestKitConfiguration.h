//
//  RestKitConfiguration.h
//  StackMobiOS
//
//  Created by Ryan Connelly on 10/9/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STMObjectMappingProvider, STMClient, STMObjectRouter;
@interface STMRestKitConfiguration : NSObject

@property (nonatomic, retain) STMObjectMappingProvider *mappingProvider;
@property (nonatomic, retain) STMClient *client;
@property (nonatomic, retain) STMObjectRouter *router;
@property BOOL inferMappingsFromObjectTypes;

+ (STMRestKitConfiguration *) configuration;

@end
