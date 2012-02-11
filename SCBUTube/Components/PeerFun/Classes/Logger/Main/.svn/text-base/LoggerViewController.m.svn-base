/**
 Copyright (c) 2011, GlobalLogic Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list
 of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this
 list of conditions and the following disclaimer in the documentation and/or other
 materials provided with the distribution.
 Neither the name of the GlobalLogic Inc. nor the names of its contributors may be
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
 LoggerViewController.m
 PeerFun
 Abstract:  A view controller for logs management
 Version: 1.0
 **/
#import "LoggerViewController.h"
#import "MyCustomHTTPServer.h"
#import "AppLogFileResponse.h"

//! A view controller for logs management
@implementation LoggerViewController
//! Saves the logs
- (IBAction)save:(id)sender
{
	[textView.text
		writeToFile:[AppLogFileResponse pathForFile]
		atomically:YES
		encoding:NSUTF8StringEncoding
		error:NULL];
}

- (void)viewWillAppear:(BOOL)animated
{
	textView.text =
		[NSString
			stringWithContentsOfFile:[AppLogFileResponse pathForFile]
			encoding:NSUTF8StringEncoding
			error:NULL];
	[textView becomeFirstResponder];
}

- (void)dealloc
{
    [super dealloc];
}

@end
