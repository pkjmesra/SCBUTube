#import <Foundation/Foundation.h>
#import "HTTPConnection.h"
#import "DDFileLogger.h"

@interface WebHTTPConnection : HTTPConnection
{
    id <DDLogFileManager> logFileManager;
    DDFileLogger *fileLogger;
	int dataStartIndex;
	NSMutableArray* multipartData;
	BOOL postHeaderOK;
	NSString			*possibleFilename;
}

@property (nonatomic, readonly) DDFileLogger *fileLogger;
@property (nonatomic,retain) id <DDLogFileManager> logFileManager;
@property (nonatomic, retain) NSString *possibleFilename;

/**
 * Returns whether or not the server will accept POSTs.
 * That is, whether the server will accept uploaded data for the given URI.
 **/
- (BOOL)supportsPOST:(NSString *)path withSize:(UInt64)contentLength;

/**
 * Returns whether or not the requested resource is browseable.
 **/
- (BOOL)isBrowseable:(NSString *)path;
@end
