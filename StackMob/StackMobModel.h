//
//  StackMobModel.h
//  StackMobiOS
//
//  Created by Douglas Rapp on 4/4/12.
//  Copyright (c) 2012 StackMob, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StackMobModel : NSObject

- (void)initWithActualClass:(Class)actualClass;

- (void)save;

- (void)fetch;

- (void)destroy;

@end
