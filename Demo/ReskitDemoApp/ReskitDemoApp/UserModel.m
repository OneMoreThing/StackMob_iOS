//
//  UserResponseData.m
//  StackMobiOS
//
//  Created by Ryan Connelly on 10/10/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

@synthesize email;
@synthesize name;
@synthesize password;
@synthesize lastmoddate;
@synthesize createddate;
@synthesize username;
@synthesize roles;

- (NSString *) schemaName
{
    return @"user";
}

- (BOOL) isEqual:(id)object
{
    return ([email isEqualToString:[object email]] &&
            [name isEqualToString:[object name]] &&
            [lastmoddate isEqual:[object lastmoddate]] &&
            [username isEqualToString:[object username]]);
}

@end
