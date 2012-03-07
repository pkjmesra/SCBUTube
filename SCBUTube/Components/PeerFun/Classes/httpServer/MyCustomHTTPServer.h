/**
 Copyright (c) 2011, Research2Development Inc.
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
 MyCustomHTTPServer.h
 PeerFun
 Abstract:  A custom http server running at iPhone client end
 Version: 1.0
 **/
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

#import "LoggerProtocol.h"

typedef enum
{
	SERVER_STATE_IDLE,
	SERVER_STATE_STARTING,
	SERVER_STATE_RUNNING,
	SERVER_STATE_STOPPING
} MyCustomHTTPServerState;

@class MyCustomHTTPResponseHandler;

//! A custom http server running at iPhone client end
@interface MyCustomHTTPServer : NSObject<LoggerProtocol>
{
	NSError *lastError;
	NSFileHandle *listeningHandle;
	CFSocketRef socket;
	MyCustomHTTPServerState state;
	CFMutableDictionaryRef incomingRequests;
	NSMutableSet *responseHandlers;
}
/**
 // setLastError:
 //
 // Custom setter method. Stops the server and 
 //
 // Parameters:
 //    anError - the new error value (nil to clear)
 **/
@property (nonatomic, readonly, retain) NSError *lastError;
/**
 // setState:
 //
 // Changes the server state and posts a notification (if the state changes).
 //
 // Parameters:
 //    newState - the new state for the server
 **/
@property (readonly, assign) MyCustomHTTPServerState state;

+ (MyCustomHTTPServer *)sharedMyCustomHTTPServer;
/**
 // start
 //
 // Creates the socket and starts listening for connections on it.
 **/
- (void)start;
/**
 // stop
 //
 // Stops the server.
 **/
- (void)stop;
/**
 // closeHandler:
 //
 // Shuts down a response handler and removes it from the set of handlers.
 //
 // Parameters:
 //    aHandler - the handler to shut down.
 **/
- (void)closeHandler:(MyCustomHTTPResponseHandler *)aHandler;

@end

extern NSString * const MyCustomHTTPServerNotificationStateChanged;
