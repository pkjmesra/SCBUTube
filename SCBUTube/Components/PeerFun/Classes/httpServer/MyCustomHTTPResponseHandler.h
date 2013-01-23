/**
 Copyright (c) 2011, Praveen K Jha, Research2Development Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list
 of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this
 list of conditions and the following disclaimer in the documentation and/or other
 materials provided with the distribution.
 Neither the name of the Research2Development Inc. nor the names of its contributors may be
 used to endorse or promote products derived from this software without specific
 prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 OF THE POSSIBILITY OF SUCH DAMAGE."
 **/
/**
 MyCustomHTTPResponseHandler.m
 PeerFun
 Abstract:  An HTTP response handler class
 Version: 1.0
 **/
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import <CFNetwork/CFNetwork.h>
#else
#import <Cocoa/Cocoa.h>
#endif

#import "LoggerProtocol.h"

@class MyCustomHTTPServer;

//! An HTTP response handler class
@interface MyCustomHTTPResponseHandler : NSObject<LoggerProtocol>
{
	CFHTTPMessageRef request;
	NSString *requestMethod;
	NSDictionary *headerFields;
	NSFileHandle *fileHandle;
	MyCustomHTTPServer *server;
	NSURL *url;
}

/**
 // priority
 //
 // The priority determines which request handlers are given the option to
 // handle a request first. The highest number goes first, with the base class
 // (HTTPResponseHandler) implementing a 501 error response at priority 0
 // (the lowest priorty).
 //
 // Even if subclasses have a 0 priority, they will always receive precedence
 // over the base class, since the base class' implementation is intended as
 // an error condition only.
 //
 // returns the priority.
 **/
+ (NSUInteger)priority;
/**
 // registerHandler:
 //
 // Inserts the HTTPResponseHandler class into the priority list.
 **/
+ (void)registerHandler:(Class)handlerClass;
/**
 // handleRequest:fileHandle:server:
 //
 // This method parses the request method and header components, invokes
 //	+[handlerClassForRequest:method:url:headerFields:] to determine a handler
 // class (if any) and creates the handler.
 //
 // Parameters:
 //    aRequest - the CFHTTPMessageRef request requiring a response
 //    requestFileHandle - the file handle for the incoming request (still
 //		open and possibly receiving data) and for the outgoing response
 //    aServer - the server that is invoking us
 //
 // returns the initialized handler (if one can handle the request) or nil
 //	(if no valid handler exists).
 **/
+ (MyCustomHTTPResponseHandler *)handlerForRequest:(CFHTTPMessageRef)aRequest
	fileHandle:(NSFileHandle *)requestFileHandle
	server:(MyCustomHTTPServer *)aServer;
/**
 // initWithRequest:method:url:headerFields:fileHandle:server:
 //
 // Init method for the handler. This method is mostly just a value copy operation
 // so that the parts of the request don't need to be reparsed.
 //
 // Parameters:
 //    aRequest - the CFHTTPMessageRef
 //    method - the request method
 //    requestURL - the URL
 //    requestHeaderFields - the CFHTTPMessageRef header fields
 //    requestFileHandle - the incoming request file handle, also used for
 //		the outgoing response.
 //    aServer - the server that spawned us
 //
 // returns the initialized object
 **/
- (id)initWithRequest:(CFHTTPMessageRef)aRequest
	method:(NSString *)method
	url:(NSURL *)requestURL
	headerFields:(NSDictionary *)requestHeaderFields
	fileHandle:(NSFileHandle *)requestFileHandle
	server:(MyCustomHTTPServer *)aServer;
/**
 // startResponse
 //
 // Begin sending a response over the fileHandle. Trivial cases can
 // synchronously return a response but everything else should spawn a thread
 // or otherwise asynchronously start returning the response data.
 //
 // THIS IS THE PRIMARY METHOD FOR SUBCLASSES TO OVERRIDE. YOU DO NOT NEED
 // TO INVOKE SUPER FOR THIS METHOD.
 //
 // This method should only be invoked from MyCustomHTTPServer (it needs to add the
 // object to its responseHandlers before this method is invoked).
 //
 // [server closeHandler:self] should be invoked when done sending data.
 **/
- (void)startResponse;
/**
 // endResponse
 //
 // Closes the outgoing file handle.
 //
 // You should not invoke this method directly. It should only be invoked from
 // MyCustomHTTPServer (it needs to remove the object from its responseHandlers before
 // this method is invoked). To close a reponse handler, use
 // [server closeHandler:responseHandler].
 //
 // Subclasses should stop any other activity when this method is invoked and
 // invoke super to close the file handle.
 //
 // If the connection is persistent, you must set fileHandle to nil (without
 // closing the file) to prevent the connection getting closed by this method.
 **/
- (void)endResponse;

@end
