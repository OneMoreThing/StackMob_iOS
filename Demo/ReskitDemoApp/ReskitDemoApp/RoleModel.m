//
//  RoleModel.m
//  ReskitDemoApp
//
//  Created by Ryan Connelly on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RoleModel.h"

@implementation RoleModel
@synthesize name;
@synthesize lastModDate;
@synthesize createDate;
@synthesize roleId;

- (NSString *) schemaName
{
    return @"role";
}

/** The name of the property that is the primary key */
- (NSString *) primaryKeyPropertyName
{
    return @"roleId";
}

@end
