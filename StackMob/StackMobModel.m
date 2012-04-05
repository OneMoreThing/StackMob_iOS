//
//  StackMobModel.m
//  StackMobiOS
//
//  Created by Douglas Rapp on 4/4/12.
//  Copyright (c) 2012 StackMob, Inc. All rights reserved.
//

#import "StackMobModel.h"

@implementation StackMobModel

Class actualClass;

- (void)initWithActualClass:(Class)actualClass {
    self.actualClass = actualClass;
}

@synthesize identifier = _identifier;

- (NSString *) schemaName
{
    return [NSString stringWithUTF8String:class_getName(actualClass)] lowercaseString];
}

- (void)save
{
    [self saveWithCallback:^(BOOL success, id result) {}];

}

- (void)saveWithCallback:(StackMobCallback)callback
{
    [[StackMob stackmob] post:[self schemaName] withArguments:nil andCallback:^(BOOL success, id result) {
        callback(success, result);
    }];
}

- (void)fetch
{
    [[StackMob stackmob] get:[NSString stringWithFormat:@"%@/%@", [self schemaName], [self identifier]] withCallback:^(BOOL success, id result) {
        //call the callback or delegate or whatever
    }];
}

- (void)destroy
{

}

@end
