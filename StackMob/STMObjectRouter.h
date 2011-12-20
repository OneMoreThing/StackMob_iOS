//
//  STMObjectRouter.h
//  StackMobiOS
//
//  Created by Ryan Connelly on 12/16/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

@interface STMObjectRouter : RKObjectRouter

- (Class) classByResourcePath:(NSString *)path forHttpVerb:(RKRequestMethod)method;

@end
