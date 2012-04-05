//
//  StackMobModel.h
//  StackMobiOS
//
//  Created by Douglas Rapp on 4/4/12.
//  Copyright (c) 2012 StackMob, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StackMob.h"
#import <runtime.h>

@interface StackMobModel : NSObject

@property (nonatomic, retain) NSString *identifier;

- (void)initWithActualClass:(Class)actualClass;

- (void)save;

- (void)saveWithCallback:(StackMobCallback)callback;

- (void)fetch;

- (void)destroy;

@end
