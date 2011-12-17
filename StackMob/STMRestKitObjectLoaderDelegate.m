//
//  RestKitObjectLoaderDelegate.m
//  StackMobiOS
//
//  Created by Ryan Connelly on 10/9/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "STMRestKitObjectLoaderDelegate.h"
#import "STMRestKitRequest.h"
#import "STMResponseError.h"

@implementation STMRestKitObjectLoaderDelegate

@synthesize requestDelegate;
@synthesize request = _request;
- (void) dealloc
{
    [super dealloc];
}

- (id) initWithRequestDelegate:(id<SMRequestDelegate>) delegate andRequest:(STMRestKitRequest *)request
{
    self = [super init];
    if(self)
    {
        requestDelegate = [delegate retain];
        _request = request;
    }
    return self;
}

- (void)requestDidStartLoad:(RKRequest *)request
{
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error
{
    self.request.loader = objectLoader;
    STMResponseError *responseError = [[[STMResponseError alloc] init] autorelease];
    responseError.error = [error localizedDescription];
    [self.request setResult:responseError];
    [self.request onRequestComplete];
    [self.requestDelegate requestCompleted: self.request];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects
{
    id result = nil;
    if([objects count] == 0) {
        result = nil;
    }
    else if([objects count] == 1)
    {
        result = [objects objectAtIndex:0];
    }
    else 
    {
        result = objects;
    }

    [self.request setResult:result];
    [self.request onRequestComplete];
    self.request.loader = objectLoader;
    [self.requestDelegate requestCompleted: self.request];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object
{
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjectDictionary:(NSDictionary*)dictionary
{
    
}

- (void)objectLoaderDidFinishLoading:(RKObjectLoader*)objectLoader
{
}

- (void)objectLoaderDidLoadUnexpectedResponse:(RKObjectLoader*)objectLoader
{   
    self.request.loader = objectLoader;
    [self.request setResult:objectLoader];
    [self.requestDelegate requestCompleted: self.request];
    [self.request onRequestComplete];
}

- (void)objectLoader:(RKObjectLoader*)loader willMapData:(inout id *)mappableData
{
    
}

@end