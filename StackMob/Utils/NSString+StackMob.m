//
//  NSString+StackMob.m
//  StackMobiOS
//
//  Created by Ryan Connelly on 12/15/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "NSString+StackMob.h"

@implementation NSString (StackMob)


- (NSString *) stringWithoutWhitespaceAndNewLineChars
{
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"self != ''"];
    
    NSArray *parts = [self componentsSeparatedByCharactersInSet:whitespaces];
    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
    NSString *result = [filteredArray componentsJoinedByString:@" "];
    return result;
}

@end
