//
//  UserResponseData.m
//  StackMobiOS
//
//  Created by Ryan Connelly on 10/10/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "UserModel.h"
#import "GroupModel.h"

@implementation UserModel

@synthesize email;
@synthesize name;
@synthesize password;
@synthesize lastModDate;
@synthesize createDate;
@synthesize userName;
@synthesize groups;

- (NSString *) schemaName
{
    return @"user";
}

- (NSString *) primaryKeyPropertyName
{
    return @"userName";
}

- (BOOL) isEqual:(id)object
{
    return ([email isEqualToString:[object email]] &&
            [name isEqualToString:[object name]] &&
            [lastModDate isEqual:[object lastModDate]] &&
            [userName isEqualToString:[object userName]]);
}


- (Class) classForRelationshipPropertyName:(NSString *)propertyName
{
    if([propertyName isEqualToString:@"groups"])
    {
        return [GroupModel class];
    }
    
    return nil;
}

@end
