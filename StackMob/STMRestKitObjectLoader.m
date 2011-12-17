//
//  RestKitObjectLoader.m
//  StackMobiOS
//
//  Created by Ryan Connelly on 10/11/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "STMRestKitObjectLoader.h"
#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "StackMobSession.h"
#import "StackMob.h"

@interface STMRestKitObjectLoader (StackMob)
- (void)addHeadersToRequest;
- (void) setRequestBody;
- (BOOL)shouldSendParams;
@end

@implementation STMRestKitObjectLoader

// Setup the NSURLRequest. The request must be prepared right before dispatching
// Overriden - add headers before setting the request body

- (BOOL)prepareURLRequest {
    
    if ((self.sourceObject && self.params == nil) && (self.method == RKRequestMethodPOST || self.method == RKRequestMethodPUT)) {
        NSAssert(self.serializationMapping, @"Cannot send an object to the remote");
        SMLog(@"POST or PUT request for source object %@, serializing to MIME Type %@ for transport...", self.sourceObject, self.serializationMIMEType);
        RKObjectSerializer* serializer = [RKObjectSerializer serializerWithObject:self.sourceObject mapping:self.serializationMapping];
        NSError* error = nil;
        id params = [serializer serializationForMIMEType:self.serializationMIMEType error:&error];	
        
        if (error) {
            SMLog(@"Serializing failed for source object %@ to MIME Type %@: %@", self.sourceObject, self.serializationMIMEType, [error localizedDescription]);
            [self didFailLoadWithError:error];
            return NO;
        }
        
        self.params = params;
    }
    
    // TODO: This is an informal protocol ATM. Maybe its not obvious enough?
    if (self.sourceObject) {
        if ([self.sourceObject respondsToSelector:@selector(willSendWithObjectLoader:)]) {
            [self.sourceObject performSelector:@selector(willSendWithObjectLoader:) withObject:self];
        }
    }
    
	[_URLRequest setHTTPMethod:[self HTTPMethod]];
	[self addHeadersToRequest]; 
    [self setRequestBody];
	 
    NSString* body = [[NSString alloc] initWithData:[_URLRequest HTTPBody] encoding:NSUTF8StringEncoding];
    SMLog(@"Prepared %@ URLRequest '%@'. HTTP Headers: %@. HTTP Body: %@.", [self HTTPMethod], _URLRequest, [_URLRequest allHTTPHeaderFields], body);
    [body release];
    
    return YES;
}

- (void)reset {
    if (_isLoading) {
        SMLog(@"Request was reset while loading: %@. Canceling.", self);
        [self cancel];
    }
    
    [_URLRequest release];
    // Always force to use OAuth1
    //if(self.authenticationType == RKRequestAuthenticationTypeOAuth1)
    //{
    StackMobSession *session = [[StackMob stackmob] session];
    OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:session.apiKey
                                                    secret:session.apiSecret] autorelease];
    
    _URLRequest = [[OAMutableURLRequest alloc] initWithURL:_URL
                                                  consumer:consumer
                                                     token:nil
                                                     realm:nil
                   
                                         signatureProvider:nil]; // use the default method, HMAC-SHA1
    //  }
    //else
    //{
    //    _URLRequest = [[NSMutableURLRequest alloc] initWithURL:_URL];
    // }
    
    
    [_URLRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [_connection release];
    _connection = nil;
    _isLoading = NO;
    _isLoaded = NO;
}

- (void)addHeadersToRequest {
    NSString* header;
    for (header in _additionalHTTPHeaders) {
        [_URLRequest setValue:[_additionalHTTPHeaders valueForKey:header] forHTTPHeaderField:header];
    }
    
    if ([self shouldSendParams]) {
		// Temporarily support older RKRequestSerializable implementations
		if ([_params respondsToSelector:@selector(HTTPHeaderValueForContentType)]) {
			[_URLRequest setValue:[_params HTTPHeaderValueForContentType] forHTTPHeaderField:@"Content-Type"];
		} else if ([_params respondsToSelector:@selector(ContentTypeHTTPHeader)]) {
			[_URLRequest setValue:[_params performSelector:@selector(ContentTypeHTTPHeader)] forHTTPHeaderField:@"Content-Type"];
		}
		if ([_params respondsToSelector:@selector(HTTPHeaderValueForContentLength)]) {
			[_URLRequest setValue:[NSString stringWithFormat:@"%d", [_params HTTPHeaderValueForContentLength]] forHTTPHeaderField:@"Content-Length"];
		}
	} else {
        [_URLRequest setValue:@"0" forHTTPHeaderField:@"Content-Length"];
    }
    
    // Add authentication headers so we don't have to deal with an extra cycle for each message requiring basic auth.
    NSAssert(self.authenticationType == RKRequestAuthenticationTypeOAuth1, @"Authentication type must be OAuth1");
    
    SMLog(@"httpMethod %@", [self HTTPMethod]);
    //if([self.method isEqualToString:@"startsession"]){
    //    [mArguments setValue:[StackMobClientData sharedClientData].clientDataString forKey:@"cd"];
    //}
    [_URLRequest setHTTPMethod:[self HTTPMethod]];
    
    [_URLRequest addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [_URLRequest addValue:@"deflate" forHTTPHeaderField:@"Accept-Encoding"];
    
    [(OAMutableURLRequest *)_URLRequest prepare];
    
    /*if (!([[self httpMethod] isEqualToString: @"GET"] || [[self httpMethod] isEqualToString:@"DELETE"])) {
     NSData* postData = [[mArguments JSONString] dataUsingEncoding:NSUTF8StringEncoding];
     SMLog(@"POST Data: %d", [postData length]);
     [request setHTTPBody:postData];	
     NSString *contentType = [NSString stringWithFormat:@"application/json"];
     [_URLRequest addValue:contentType forHTTPHeaderField: @"Content-Type"]; 
     }
     */
    
    
    if (self.cachePolicy & RKRequestCachePolicyEtag) {
        NSString* etag = [self.cache etagForRequest:self];
        if (etag) {
            [_URLRequest setValue:etag forHTTPHeaderField:@"If-None-Match"];
        }
    }
}

@end
