//
//  RestKitObjectManager.m
//  StackMobiOS
//
//  Created by Ryan Connelly on 10/11/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "STMRestKitObjectManager.h"
#import "STMRestKitObjectLoader.h"

@implementation STMRestKitObjectManager

- (RKObjectLoader*)objectLoaderWithResourcePath:(NSString*)resourcePath delegate:(id<RKObjectLoaderDelegate>)delegate {
    RKObjectLoader* objectLoader = nil;
    Class managedObjectLoaderClass = NSClassFromString(@"RKManagedObjectLoader");
    if (self.objectStore && managedObjectLoaderClass) {
        objectLoader = [managedObjectLoaderClass loaderWithResourcePath:resourcePath objectManager:self delegate:delegate];
    } else {
        objectLoader = [STMRestKitObjectLoader loaderWithResourcePath:resourcePath objectManager:self delegate:delegate];
    }	
    
	return objectLoader;
}

+ (RKObjectManager*)objectManagerWithBaseURL:(NSString*)baseURL {
	RKObjectManager* manager = [[[self alloc] initWithBaseURL:baseURL] autorelease];
	if ([RKObjectManager sharedManager] == nil) {
		[RKObjectManager setSharedManager:manager];
	}
	return manager;
}

@end
