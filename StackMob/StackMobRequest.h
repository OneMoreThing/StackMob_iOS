// Copyright 2011 StackMob, Inc
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "StackMobSession.h"
#import "StackMobConfiguration.h"
#import "StackMobQuery.h"
#import "External/RestKit/Vendor/JSONKit/JSONKit.h"
#import <RestKit/RestKit.h>

@class StackMob;
typedef void (^StackMobCallback)(BOOL success, id result);

typedef enum {
	GET,
	POST,
	PUT,
	DELETE
} SMHttpVerb;

@interface StackMobRequest : NSObject <RKRequestDelegate>
{
	NSURLConnection*		mConnection;
	SEL						mSelector;
    BOOL          mIsSecure;
	NSMutableDictionary*	mArguments;
    NSMutableDictionary*    mHeaders;
    NSData*                 mBody;
	NSMutableData*			mConnectionData;
	NSDictionary*			mResult;
    NSError*                mConnectionError;
	BOOL					_requestFinished;
	NSHTTPURLResponse*		mHttpResponse;
    RKRequest*              mBackingRequest;
    StackMobCallback        mCallback;
	
	@protected
    BOOL userBased;
	StackMobSession *session;
}

@property(readwrite, retain) id delegate;
@property(readwrite, assign, getter=getMethod, setter=setMethod:) NSString* method;
@property(readwrite, assign, getter=getHTTPMethod, setter=setHTTPMethod:) SMHttpVerb httpMethod;
@property(readwrite) BOOL isSecure;
@property(readwrite, retain) NSDictionary* result;
@property(readwrite, retain) NSError* connectionError;
@property(readwrite, retain) NSData *body;
@property(readonly) BOOL finished;
@property(readonly) NSHTTPURLResponse* httpResponse;
@property(readonly, getter=getStatusCode) NSInteger statusCode;
@property(readonly, getter=getBaseURL) NSString* baseURL;
@property(readonly, getter=getURL) NSURL* url;
@property(nonatomic) BOOL userBased;
@property(readwrite, retain) RKRequest* backingRequest;
@property(readwrite, retain) StackMobCallback callback;

+ (NSString*)stringFromHttpVerb:(SMHttpVerb)httpVerb;

/* 
 * Standard CRUD requests
 */
+ (id)request;
//Remove before release
+ (id)requestFromRestKit:(RKRequest*)req;
+ (id)requestForMethod:(NSString*)method;
+ (id)requestForMethod:(NSString*)method withHttpVerb:(SMHttpVerb) httpVerb;
+ (id)requestForMethod:(NSString*)method withArguments:(NSDictionary*)arguments withHttpVerb:(SMHttpVerb) httpVerb;
+ (id)requestForMethod:(NSString*)method withQuery:(StackMobQuery *)query withHttpVerb:(SMHttpVerb) httpVerb;
+ (id)requestForMethod:(NSString *)method withData:(NSData *)data;

/* 
 * User based requests 
 * Use these to execute a method on a user object
 */
+ (id)userRequest;
+ (id)userRequestForMethod:(NSString *)method withHttpVerb:(SMHttpVerb)httpVerb;
+ (id)userRequestForMethod:(NSString*)method withArguments:(NSDictionary*)arguments withHttpVerb:(SMHttpVerb)httpVerb;
+ (id)userRequestForMethod:(NSString *)method withQuery:(StackMobQuery *)query withHttpVerb:(SMHttpVerb)httpVerb;

/*
 * Create a request for an iOS PUSH notification
 * @param arguments a dictionary of arguments including :alert, :badge and :sound
 */
+ (id)pushRequestWithArguments:(NSDictionary*)arguments withHttpVerb:(SMHttpVerb) httpVerb;

/**
 * Convert a NSDictionary to JSON
 * @param dict the dictionary to convert to JSON
 */
+ (NSData *)JsonifyNSDictionary:(NSMutableDictionary *)dict withErrorOutput:(NSError **)error;

/*
 * Set parameters for requests
 */
- (void)setArguments:(NSDictionary*)arguments;
/*
 * Set headers for requests, overwrites all headers set for the request
 * @param headers, the headers to set
 */
- (void)setHeaders:(NSDictionary *)headers;

/*
 * Send a configured request and wait for callback
 */
- (void)sendRequest;

/*
 * Cancel and ignore a request in progress
 */
- (void)cancel;


@end

@protocol SMRequestDelegate <NSObject>

@optional
- (void)requestCompleted:(StackMobRequest *)request;

@end


