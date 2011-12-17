//
//  RestKitObjectLoaderDelegate.h
//  StackMobiOS
//
//  Created by Ryan Connelly on 10/9/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "StackMobRequest.h"
@class SMRequestDelegate, STMRestKitRequest;
@interface STMRestKitObjectLoaderDelegate : NSObject <RKObjectLoaderDelegate>
{
    id<SMRequestDelegate> requestDelegate;
    STMRestKitRequest *_request;
}

- (id) initWithRequestDelegate:(id<SMRequestDelegate>) delegate andRequest:(STMRestKitRequest *)request;

@property (nonatomic, assign) STMRestKitRequest *request;
@property (nonatomic, retain) id<SMRequestDelegate> requestDelegate;
@end
