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
 File: LoggerAppDelegate.m
 Abstract: A Logger application delegate that can be used independently for logging purposes
 **/
#import "LoggerAppDelegate.h"
#import "LoggerViewController.h"
#import "MyCustomHTTPServer.h"
#import "AppLogFileResponse.h"
#import <foundation/foundation.h>
#import <mach-o/nlist.h>
#import <string.h>

BOOL __allowAll =YES;

extern void instrumentObjcMessageSends(BOOL); 
//int objcMsgLogFD =-1;
int __counter =0;
/**
 Overrides and swizzles the default ObjCMessageSend method for app logging
 **/
int MyLogObjCMessageSend (BOOL isClassMethod,
						  const char * objectsClass,
						  const char * implementingClass,
						  SEL selector)
{
    
//    char	buf[ 1024 ];
//    
//    // Create/open the log file
//    if (objcMsgLogFD == (-1))
//    {
//        snprintf (buf, sizeof(buf), "/tmp/msgSends-%d", (int) getpid ());
//        objcMsgLogFD = secure_open (buf, O_WRONLY | O_CREAT, geteuid());
//        if (objcMsgLogFD < 0) {
//            // no log file - disable logging
//            objcMsgLogEnabled = 0;
//            objcMsgLogFD = -1;
//            return 1;
//        }
//    }
//    
//    // Make the log entry
//    snprintf(buf, sizeof(buf), "%c %s %s %s\n",
//             isClassMethod ? '+' : '-',
//             objectsClass,
//             implementingClass,
//             (char *) selector);
//    
//    static OSSpinLock lock = OS_SPINLOCK_INIT;
//    OSSpinLockLock(&lock);
//    write (objcMsgLogFD, buf, strlen(buf));
//    OSSpinLockUnlock(&lock);
//    
//    // Tell caller to not cache the method
//    return 0;

	BOOL isMyCustom;
    
    if(!__allowAll)
    {
        char c[8]; int i;
        for (i=0; i<=7; i++) {
            c[i] = *(objectsClass +i);
            switch (i) {
                case 0:
                    if(c[i] !='M') return 0;
                    break;
                case 1:
                    if(c[i] !='y') return 0;
                    break;
                case 2:
                    if(c[i] !='C') return 0;
                    break;
                case 3:
                    if(c[i] !='u') return 0;
                    break;
                case 4:
                    if(c[i] !='s') return 0;
                    break;
                case 5:
                    if(c[i] !='t') return 0;
                    break;
                case 6:
                    if(c[i] !='o') return 0;
                    break;
                case 7:
                    if(c[i] !='m') 
                        return 0;
                    else 
                        isMyCustom = YES;
                    
                    break;
                default:
                    break;
            }
        }
    }
    
	if(isMyCustom || __allowAll)
	{
		// Make the log entry -- Replace this function's code by anything you want
		NSLog( @"Line %d-> %c %s %s %s\n",
              ++__counter,
			  isClassMethod ? '+' : '-',
			  objectsClass,
			  implementingClass,
			  (char *) selector);
	}
	return 0;
}

//! A Logger application delegate that can be used independently for logging purposes
@implementation LoggerAppDelegate

@synthesize window;
@synthesize viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{    
	NSString *logPath = [AppLogFileResponse pathForFile];

	NSLog(@"Application started");
    
	// Begin code for replacing libobjc logging function
	typedef int (*ObjCLogProc)(BOOL, const char *, const char *, SEL);
	typedef int (*LogObjcMessageSendsFunc)(ObjCLogProc);
	LogObjcMessageSendsFunc fcn;
	
	struct nlist nl[3];
	bzero(&nl, sizeof(struct nlist) * 3);
	nl[0].n_un.n_name = "_instrumentObjcMessageSends";
	nl[1].n_un.n_name = "_logObjcMessageSends";
	
    NSLog(@"nlist returned %d",nlist("/usr/lib/libobjc.A.dylib", nl));
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
	freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
	// Replace libobjc.A.dylib by whatever version you're using
	if (nlist("/usr/lib/libobjc.A.dylib", nl) < 0 || nl[0].n_type == N_UNDF) {
		NSLog(@"nlist(%s, %s) failed\n","/usr/lib/libobjc.A.dylib",nl[0].n_un.n_name);
        if (nlist("/usr/lib/libobjc.dylib", nl) < 0 || nl[0].n_type == N_UNDF) {
                NSLog(@"nlist(%s, %s) failed\n","/usr/lib/libobjc.dylib",nl[0].n_un.n_name);
            }
	}
    // This line locates libobjc.A.dylib in the memory by getting the address of the symbol
    // instrumentObjcMessageSends contained in this library. To get to the non-exported symbol,
    // we just add the offset between the two symbols which we got by nlist
    fcn = (LogObjcMessageSendsFunc)( (long) (&instrumentObjcMessageSends) + (nl[1].n_value-nl[0].n_value));
    fcn(&MyLogObjCMessageSend);
    // End code for replacing libobjc logging function
	instrumentObjcMessageSends(YES);
	[[MyCustomHTTPServer sharedMyCustomHTTPServer] start];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[MyCustomHTTPServer sharedMyCustomHTTPServer] stop];
}

- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
