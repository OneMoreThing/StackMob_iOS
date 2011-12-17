//
//  StackMobMappedObject.h
//  StackMobiOS
//
//  Created by Ryan Connelly on 12/16/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  Protocol that is required to be implemented for all mapped 
 *  objects. 
*/


@protocol STMMappedObject <NSObject>

/** 
 *  The name of the schema as defined by the schema configuration with stackmob.
 *  All stackmob mapped objects must implement this protocol.
 */
- (NSString *) schemaName;

/** 
 *  All relationships must be defined via this class.
 *  Returning nil will result in the relationship not being mapped.
 *  Example:
 *  For the propertyName "addresses", you would return a class
 *  like "AddressModel".
 *
 */
- (Class) classForRelationshipPropertyName:(NSString *)propertyName;

@end
