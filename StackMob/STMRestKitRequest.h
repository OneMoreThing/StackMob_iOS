//
//  RestkitRequest.h
//  StackMobiOS
//
//  Created by Ryan Connelly on 10/9/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "StackMobBulkRequest.h"
@class STMRestKitObjectLoaderDelegate;
@interface STMRestKitRequest : StackMobBulkRequest <RKOAuthClientDelegate>
@property (nonatomic, retain) STMRestKitObjectLoaderDelegate *loaderDelegate;
@property (nonatomic, retain) RKObjectLoader *loader;
@property (nonatomic, retain) RKObjectManager *objectManager;   
@property (nonatomic, retain) RKOAuthClient *authClient;

- (void) onRequestComplete;

@end
