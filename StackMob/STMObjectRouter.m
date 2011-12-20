//
//  STMObjectRouter.m
//  StackMobiOS
//
//  Created by Ryan Connelly on 12/16/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "STMObjectRouter.h"

@interface STMObjectRouter (Private)
- (NSString*)HTTPVerbForMethod:(RKRequestMethod)method;
@end

@implementation STMObjectRouter

- (Class) classByResourcePath:(NSString *)path forHttpVerb:(RKRequestMethod)method
{
    
    NSString *methodString = [self HTTPVerbForMethod:method];
    NSSet *results = [_routes keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return [[[obj valueForKey:methodString] valueForKey:@"resourcePath"] isEqualToString:path];
    }];
    
    if([results count] == 0)
    {
        results = [_routes keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
            return [[[obj valueForKey:@"ANY"] valueForKey:@"resourcePath"] isEqualToString:path];
        }];
    }
    
    return [results anyObject];
}

@end
