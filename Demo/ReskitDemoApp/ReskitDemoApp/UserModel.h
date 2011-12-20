//
//  UserResponseData.h
//  StackMobiOS
//
//  Created by Ryan Connelly on 10/10/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StackMob/STMMappedObject.h"

@class RoleModel;
@interface UserModel : NSObject <STMMappedObject>

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSNumber *lastModDate;
@property (nonatomic, strong) NSNumber *createDate;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *email;

@property (nonatomic, strong) NSArray *groups;

@end
