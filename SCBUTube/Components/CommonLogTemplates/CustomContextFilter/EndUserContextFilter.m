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
