//
//  StackMobMappingProvider.h
//  StackMobiOS
//
//  Created by Ryan Connelly on 12/15/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STMObjectRouter, STMObjectMapping;

/**
 *  StackMob's implementation of a mapping provider. Provides a 
 *  simplified interface for working with objects within StackMob schemas. The implementation
 *  favors convention over configuration and thus is very simple.
 *
 *  Mapping by Convention
 *  
 *  Object Properties
 *
 *  Fields
 *  Any read/writeable property will be mapped to schema fields using the following rules:
 *  - Any property that ends with "Id" (case sensitive) will be converted to the standard object_id field format for primary keys.
 *  - Properties must have a matching class type with corresponding field.
 *  - All property names are mapped to lowercase names to match stackmob's standard schemas.
 *
 *  Examples:
 *  userName would map to username
 *  eventId would map to event_id  
 *  testbug would map to testbug
 *
 *  Relationships
 *  - classForRelationshipPropertyName: must be implemented to handle relationship properties
 *  - One-to-many relationship properties must use NSMutableArray.
 */

@interface STMObjectMappingProvider : NSObject
{
    RKObjectMappingProvider *internalProvider;
    STMObjectRouter *router; // weak reference
}

- (id)initWithRouter:(STMObjectRouter *)r;


/** 
 * Registers an array of object mappings. Will handle registering serialization as well. Routes 
 * are also setup based on StackMob's restful service implementation.
 * @param objectMappings the mapping to register with the provider
 * @param router the router to which objects are mapped with urls and http verbs.
 */

- (void) registerObjectMappings:(NSArray *)objectMappings;

/** 
 * Registers an object mapping. Will handle registering serialization as well. Routes 
 * are also setup based on StackMob's restful service implementation.
 * @param objectMapping the mapping to register with the provider
 * @param router the router to which objects are mapped with urls and http verbs.
 */

- (void) registerObjectMapping:(STMObjectMapping *)objectMapping;

- (id<RKObjectMappingDefinition>)objectMappingForKeyPath:(NSString *)keyPath;
- (NSDictionary*)objectMappingsByKeyPath;
- (RKObjectMapping*)serializationMappingForClass:(Class)objectClass;
- (NSArray *)objectMappingsForClass:(Class)theClass;

@end
