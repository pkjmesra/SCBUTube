/**
 Copyright (c) 2011, Praveen K Jha, .
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list
 of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this
 list of conditions and the following disclaimer in the documentation and/or other
 materials provided with the distribution.
 Neither the name of the . nor the names of its contributors may be
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
#import "EndUserContextFilter.h"
#import "EndUserLogging.h"


@implementation EndUserContextFilter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
	if (logMessage->logContext != END_USER_LOG_CONTEXT)
	{
		// We can filter this message by simply returning nil
		return nil;
	}
	else
	{
		// Log only messages meant for logging by end user logging module
		return [NSString stringWithFormat:@"%@ | %s @ %i | %@",
				[logMessage fileName], logMessage->function, logMessage->lineNumber, logMessage->logMsg];
	}
}

/**
	Returns the logs directory for creating the log files.
*/
-(NSString*) logsDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *logFilePath = [[NSString alloc] initWithString:[[paths objectAtIndex:0] 
															  stringByAppendingPathComponent:@"logs"]];
	return logFilePath;
}

/**
Returns the current time stamp in yyyy-MM-dd_HH-mm-ss formatted string.
 */
-(NSString *) logFileNameWithoutPath
{
	NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init]autorelease];
	[dateFormat setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
	return [NSString stringWithFormat:@"NewFile_%@", [dateFormat stringFromDate:[NSDate date]]];
	
}

@end
