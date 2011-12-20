//
//  RoleModel.h
//  ReskitDemoApp
//
//  Created by Ryan Connelly on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StackMob/STMMappedObject.h"

@interface GroupModel : NSObject  <STMMappedObject>

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *lastModDate;
@property (nonatomic, strong) NSNumber *createDate;

@end
