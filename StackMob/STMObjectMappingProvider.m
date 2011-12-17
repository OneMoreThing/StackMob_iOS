//
//  StackMobMappingProvider.m
//  StackMobiOS
//
//  Created by Ryan Connelly on 12/15/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "STMObjectMappingProvider.h"
#import "STMResponseError.h"
#import "STMMappedObject.h"
#import "STMObjectRouter.h"
#import "STMObjectMapping.h"

@implementation STMObjectMappingProvider

+ (STMObjectMappingProvider *) objectMappingProvider {
    return [[self new] autorelease];
}

- (void)dealloc {
    [internalProvider release];
    [super dealloc];
}

- (id)initWithRouter:(STMObjectRouter *)r {
    self = [super init];
    if (self) {
        internalProvider = [[RKObjectMappingProvider alloc] init];
        router = r;
    }
    return self;
}

- (void) registerObjectMappings:(NSArray *)objectMappings
{
    for(STMObjectMapping *objectMapping in objectMappings)
    {
        [self registerObjectMapping:objectMapping];
    }
}

- (void) registerObjectMapping:(STMObjectMapping *)objectMapping
{
    objectMapping.rootKeyPath = @"";
    
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[STMResponseError class] block:^(RKObjectMapping *m){
        [m mapAttributes:@"error",nil]; 
    }];
    
    id<STMMappedObject> obj = [[[objectMapping.objectClass alloc] init] autorelease];
    
    // Register all verbs 
    NSString *resourcePath = [NSString stringWithFormat:@"/%@",[obj schemaName]];
    [router routeClass:objectMapping.objectClass toResourcePath:resourcePath];
    
    // Setup a dynamic mapping to handle error messages
    RKDynamicObjectMapping* dynamicMapping = [RKDynamicObjectMapping dynamicMapping];
    
    dynamicMapping.objectMappingForDataBlock = ^ RKObjectMapping* (id mappableData) {
        if ([[mappableData valueForKey:@"error"] isEqualToString:nil]) {
            return objectMapping;
        } else {
            return errorMapping;
        }
    };
    
    // No "wrapped" namesapce objects i.e. NOT { "user" : { "username" : "john", "password", "pass123" } }
    [internalProvider setMapping:dynamicMapping forKeyPath:@""];
    RKObjectMapping *inverseMapping = [objectMapping inverseMapping];
    [internalProvider setSerializationMapping:inverseMapping forClass:objectMapping.objectClass];
}


#pragma mark - RKObjectMappingProvider wrapper methods

- (id<RKObjectMappingDefinition>)objectMappingForKeyPath:(NSString *)keyPath {
    return [internalProvider objectMappingForKeyPath:keyPath];
}

- (RKObjectMapping*)serializationMappingForClass:(Class)objectClass {
    return [internalProvider serializationMappingForClass:objectClass];
}

- (NSDictionary*)objectMappingsByKeyPath {
    return [internalProvider objectMappingsByKeyPath];
}

- (NSArray *)objectMappingsForClass:(Class)theClass {
    return [internalProvider objectMappingsForClass:theClass];
}

- (RKObjectMapping *)objectMappingForClass:(Class)theClass {
    return [internalProvider objectMappingForClass:theClass];
}

+ (STMObjectMappingProvider *)mappingProvider {
    return [STMObjectMappingProvider objectMappingProvider];
}

- (RKObjectMapping *)mappingForKeyPath:(NSString *)keyPath {
    return [internalProvider mappingForKeyPath:keyPath];
}

- (void)setMapping:(RKObjectMapping *)mapping forKeyPath:(NSString *)keyPath {
    return [internalProvider setMapping:mapping forKeyPath:keyPath];
}

- (NSDictionary *)mappingsByKeyPath
{
    return [internalProvider mappingsByKeyPath];
}


@end
