//
//  STMObjectMapping.m
//  StackMobiOS
//
//  Created by Ryan Connelly on 12/16/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "STMObjectMapping.h"
#import "objc/runtime.h"

@interface STMObjectMapping()

+ (STMObjectMapping *) objectMappingForCollection:(id)list objectClass:(Class)objectClass;

@end

@implementation STMObjectMapping

+ (STMObjectMapping *) objectMappingForCollection:(id)list objectClass:(Class)objectClass
{
    return nil;
}

const char * property_getTypeString( objc_property_t property )
{
	const char * attrs = property_getAttributes( property );
	if ( attrs == NULL )
		return ( NULL );
    
	static char buffer[256];
	const char * e = strchr( attrs, ',' );
	if ( e == NULL )
		return ( NULL );
    
	int len = (int)(e - attrs);
	memcpy( buffer, attrs, len );
	buffer[len] = '\0';

    return buffer;
}

+ (NSArray *) defaultMappingsForClasses:(Class)objectClass, ...
{
    va_list args;
    va_start(args, objectClass);
    NSMutableArray *returnValue = [NSMutableArray array];
    for (Class objClass = objectClass; objClass != nil; objClass = va_arg(args, Class)) {
            RKObjectMapping *mapping = [self mappingForClass:objClass block:^(RKObjectMapping *m) {
                // find all available properties
                unsigned int outCount, i;
                objc_property_t *properties = class_copyPropertyList(objClass, &outCount);
                for (i = 0; i < outCount; i++) {
                    objc_property_t property = properties[i];
                    
                    
                    NSString *className = [NSString stringWithCString:property_getTypeString(property) encoding:NSUTF8StringEncoding];
                   // NSClassFromString();
                    className = nil;
                    NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
                    [m mapKeyPath:[propertyName lowercaseString] toAttribute:propertyName];
                }
            }];
        [returnValue addObject:mapping];
        
    }
    va_end(args);
    
    return returnValue;
}

@end
