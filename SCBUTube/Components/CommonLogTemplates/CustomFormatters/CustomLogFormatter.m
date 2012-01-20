#import "CustomLogFormatter.h"


@implementation CustomLogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
	return [NSString stringWithFormat:@"%@ | %s @ %i | %@",
			[logMessage fileName], logMessage->function, logMessage->lineNumber, logMessage->logMsg];
}

@end
