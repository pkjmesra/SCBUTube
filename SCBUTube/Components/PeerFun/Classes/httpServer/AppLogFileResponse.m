/**
 Copyright (c) 2011, Praveen K Jha, Praveen K Jha.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list
 of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this
 list of conditions and the following disclaimer in the documentation and/or other
 materials provided with the distribution.
 Neither the name of the Praveen K Jha. nor the names of its contributors may be
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
 AppLogFileResponse.m
 PeerFun
 Abstract:  A response handler class to send all the response from a log file
 Version: 1.0
 **/
#import "AppLogFileResponse.h"
#import "MyCustomHTTPServer.h"

//! A response handler class to send all the response from a log file
@implementation AppLogFileResponse

/**
// load
//
// Implementing the load method and invoking
// [HTTPResponseHandler registerHandler:self] causes HTTPResponseHandler
// to register this class in the list of registered HTTP response handlers.
//
**/
+ (void)load
{
	[MyCustomHTTPResponseHandler registerHandler:self];
}

/**
// canHandleRequest:method:url:headerFields:
//
// Class method to determine if the response handler class can handle
// a given request.
//
// Parameters:
//    aRequest - the request
//    requestMethod - the request method
//    requestURL - the request URL
//    requestHeaderFields - the request headers
//
// returns YES (if the handler can handle the request), NO (otherwise)
**/
+ (BOOL)canHandleRequest:(CFHTTPMessageRef)aRequest
	method:(NSString *)requestMethod
	url:(NSURL *)requestURL
	headerFields:(NSDictionary *)requestHeaderFields
{
	if ([requestURL.path isEqualToString:@"/"])
	{
		return YES;
	}
	
	return NO;
}

/**
// startResponse
//
// Since this is a simple response, we handle it synchronously by sending
// everything at once.
**/
- (void)startResponse
{
	NSData *fileData =
		[NSData dataWithContentsOfFile:[AppLogFileResponse pathForFile]];

	CFHTTPMessageRef response =
		CFHTTPMessageCreateResponse(
			kCFAllocatorDefault, 200, NULL, kCFHTTPVersion1_1);
	CFHTTPMessageSetHeaderFieldValue(
		response, (CFStringRef)@"Content-Type", (CFStringRef)@"text/plain");
	CFHTTPMessageSetHeaderFieldValue(
		response, (CFStringRef)@"Connection", (CFStringRef)@"close");
	CFHTTPMessageSetHeaderFieldValue(
		response,
		(CFStringRef)@"Content-Length",
		(CFStringRef)[NSString stringWithFormat:@"%ld", [fileData length]]);
	CFDataRef headerData = CFHTTPMessageCopySerializedMessage(response);

	@try
	{
		[fileHandle writeData:(NSData *)headerData];
		[fileHandle writeData:fileData];
	}
	@catch (NSException *exception)
	{
		// Ignore the exception, it normally just means the client
		// closed the connection from the other end.
	}
	@finally
	{
		NSLog(@"Sent response from text log");
		//[NSString stringWithUTF8String:__func__];
		CFRelease(headerData);
		[server closeHandler:self];
	}
}

/**
// pathForFile
//
// In this sample application, the only file returned by the server lives
// at a fixed location, whose path is returned by this method.
//
// returns the path of the text file.
**/
+ (NSString *)pathForFile
{
	NSLog(@"%@ %@:", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	//[NSString stringWithUTF8String:__func__];
	int pid = [[NSProcessInfo processInfo] processIdentifier]; 
	NSString *fileName = [NSString stringWithFormat:@"msgSends-%d",pid];
	NSString *path = @"/tmp/";
		//[NSSearchPathForDirectoriesInDomains(
//				NSCachesDirectory,
//				NSUserDomainMask,
//				YES)
//			objectAtIndex:0];
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path];
	if (!exists)
	{
		[[NSFileManager defaultManager]
			createDirectoryAtPath:path
			withIntermediateDirectories:YES
			attributes:nil
			error:nil];
	}
	NSLog(@"File Path set to :%@",[path stringByAppendingPathComponent:fileName]);
	return [path stringByAppendingPathComponent:fileName];
}

@end
