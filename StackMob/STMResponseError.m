//
//  StackMobResponseError.m
//  StackMobiOS
//
//  Created by Ryan Connelly on 12/15/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "STMResponseError.h"

@implementation STMResponseError
@synthesize error;

- (void)dealloc {
    [error release];
    [super dealloc];
}


- (NSString *) description
{
    return self.error;
}

@end
