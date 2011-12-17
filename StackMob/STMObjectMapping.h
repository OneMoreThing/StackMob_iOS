//
//  STMObjectMapping.h
//  StackMobiOS
//
//  Created by Ryan Connelly on 12/16/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

@interface STMObjectMapping : RKObjectMapping

+ (NSArray *) defaultMappingsForClasses:(Class)objectClass, ... NS_REQUIRES_NIL_TERMINATION;

@end
