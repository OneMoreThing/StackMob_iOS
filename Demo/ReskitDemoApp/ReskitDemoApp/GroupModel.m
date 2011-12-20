//
//  RoleModel.m
//  ReskitDemoApp
//
//  Created by Ryan Connelly on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GroupModel.h"
#import "RoleModel.h"

@implementation GroupModel
@synthesize name;
@synthesize groupId;
@synthesize lastModDate;
@synthesize createDate;

- (NSString *) schemaName
{
    return @"group";
}

- (NSString *) primaryKeyPropertyName
{
    return @"groupId";
}

- (Class) classForRelationshipPropertyName:(NSString *)propertyName
{
    if([propertyName isEqualToString:@"roles"])
    {
        return [RoleModel class];
    }
    
    return nil;
}

@end
