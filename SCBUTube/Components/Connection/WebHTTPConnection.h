#import <Foundation/Foundation.h>
#import "HTTPConnection.h"
#import "DDFileLogger.h"

@interface WebHTTPConnection : HTTPConnection
{
    id <DDLogFileManager> logFileManager;
    DDFileLogger *fileLogger;
}

@property (nonatomic, readonly) DDFileLogger *fileLogger;
@property (nonatomic,retain) id <DDLogFileManager> logFileManager;
@end
