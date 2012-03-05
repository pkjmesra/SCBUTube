#import "WebHTTPConnection.h"
#import "HTTPLogging.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "HTTPFileResponse.h"
#import "HTTPDynamicFileResponse.h"
#import "GCDAsyncSocket.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "WebSocket.h"
//#import "WebSocketLogger.h"

#import <UIKit/UIKit.h>

#import "Objective_Zipper.h"

@implementation WebHTTPConnection

@synthesize logFileManager;
@synthesize fileLogger;

-(id <DDLogFileManager>) getLoggerManager
{
    if (self.logFileManager == nil)
    {
		// Check if the UIApplicationDelegate has a fileLogger
		if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(fileLogger)])
		{
			return [[[[UIApplication sharedApplication] delegate] fileLogger] logFileManager];
		}
		else
		{
			// Direct log messages to the console.
			// The log messages will look exactly like a normal NSLog statement.
			// 
			// This is something we may not want to do in a shipping version of the application.
			
			//	[DDLog addLogger:[DDASLLogger sharedInstance]];
			[DDLog addLogger:[DDTTYLogger sharedInstance]];
			
			// We also want to direct our log messages to a file.
			// So we're going to setup file logging.
			// 
			// We start by creating a file logger.
			
			fileLogger = [[DDFileLogger alloc] init];
			
			// Configure some sensible defaults for an iPhone application.
			// 
			// Roll the file when it gets to be 512 KB or 24 Hours old (whichever comes first).
			// 
			// Also, only keep up to 4 archived log files around at any given time.
			// We don't want to take up too much disk space.
			
			fileLogger.maximumFileSize = 1024 * 512;    // 512 KB
			fileLogger.rollingFrequency = 60 * 60 * 24; //  24 Hours
			
			fileLogger.logFileManager.maximumNumberOfLogFiles = 20;
			
			// Add our file logger to the logging system.
			
			[DDLog addLogger:fileLogger];
			return fileLogger.logFileManager;
		}
    }
    else
    {
        return self.logFileManager;
    }
}

- (NSData *)generateIndexData
{
	NSArray *sortedLogFileInfos = [[self getLoggerManager] sortedLogFileInfos];
	
	NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
	[df setFormatterBehavior:NSDateFormatterBehavior10_4];
	[df setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
	
	NSNumberFormatter *nf = [[[NSNumberFormatter alloc] init] autorelease];
	[nf setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[nf setNumberStyle:NSNumberFormatterDecimalStyle];
	[nf setMinimumFractionDigits:2];
	[nf setMaximumFractionDigits:2];
	
	NSMutableString *response = [NSMutableString stringWithCapacity:1000];
	
	[response appendString:@"<html><head>"];
	[response appendString:@"<style type='text/css'>@import url('styles.css');</style>"];
	[response appendString:@"</head><body>"];
	
	[response appendString:@"<h1>Device Log Files</h1>"];
	
	[response appendString:@"<table cellspacing='2'>"];
	
	for (DDLogFileInfo *logFileInfo in sortedLogFileInfos)
	{
		NSString *fileName = logFileInfo.fileName;
		NSString *fileDate = [df stringFromDate:[logFileInfo creationDate]];
		NSString *fileSize;
		
		unsigned long long sizeInBytes = logFileInfo.fileSize;
		
		double GBs = (double)(sizeInBytes) / (double)(1024 * 1024 * 1024);
		double MBs = (double)(sizeInBytes) / (double)(1024 * 1024);
		double KBs = (double)(sizeInBytes) / (double)(1024);
		
		if(GBs >= 1.0)
		{
			NSString *temp = [nf stringFromNumber:[NSNumber numberWithDouble:GBs]];
			fileSize = [NSString stringWithFormat:@"%@ GB", temp];
		}
		else if(MBs >= 1.0)
		{
			NSString *temp = [nf stringFromNumber:[NSNumber numberWithDouble:MBs]];
			fileSize = [NSString stringWithFormat:@"%@ MB", temp];
		}
		else
		{
			NSString *temp = [nf stringFromNumber:[NSNumber numberWithDouble:KBs]];
			fileSize = [NSString stringWithFormat:@"%@ KB", temp];
		}
		
		NSString *fileLink = [NSString stringWithFormat:@"<a href='/logs/%@'>%@</a>", fileName, fileName];
		
		[response appendFormat:@"<tr><td>%@</td><td>%@</td><td align='right'>%@</td>", fileLink, fileDate, fileSize];
	}
	
	[response appendString:@"</table></body></html>"];
	
	return [response dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)generateDocumentsDirectoryData:(NSString *)path
{	
	NSString *docFullPath = [NSString stringWithFormat:@"%@%@/",[config.documentRoot stringByReplacingOccurrencesOfString:@"/Documents" withString:@""],[path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSLog(@"docFullPath :%@",docFullPath);
	NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
	[df setFormatterBehavior:NSDateFormatterBehavior10_4];
	[df setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
	
	NSNumberFormatter *nf = [[[NSNumberFormatter alloc] init] autorelease];
	[nf setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[nf setNumberStyle:NSNumberFormatterDecimalStyle];
	[nf setMinimumFractionDigits:2];
	[nf setMaximumFractionDigits:2];
	
	NSMutableString *response = [NSMutableString stringWithCapacity:1000];
	
	[response appendString:@"<html><head>"];
	[response appendString:@"<style type='text/css'>@import url('styles.css');</style>"];
	[response appendString:@"</head><body>"];
	
	[response appendString:@"<h1>Device Files</h1>"];
	
	[response appendString:@"<table cellspacing='2'>"];
	
	NSString* file;
	NSMutableDictionary *subDirectories=[[NSMutableDictionary alloc] initWithCapacity:0];
	NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtPath:docFullPath];
	while (file = [enumerator nextObject])
	{
		// check if it's a directory
		BOOL isDirectory = NO;
		BOOL isSubDirectory=NO;
		[[NSFileManager defaultManager] fileExistsAtPath: [NSString stringWithFormat:@"%@/%@",docFullPath,file]
											 isDirectory:&isDirectory];
		[[NSFileManager defaultManager] fileExistsAtPath: [NSString stringWithFormat:@"%@/%@",docFullPath,[[file pathComponents] objectAtIndex:0]]
											 isDirectory:&isSubDirectory];
		if (!isDirectory && !isSubDirectory)
		{
			// open your file …
			DDLogFileInfo *logFileInfo = [[DDLogFileInfo alloc ]initWithFilePath:[NSString stringWithFormat:@"%@/%@",docFullPath,file]];
//			NSString *fileName = logFileInfo.fileName;
			NSString *fileDate = [df stringFromDate:[logFileInfo creationDate]];
			NSString *fileSize;
			
			unsigned long long sizeInBytes = logFileInfo.fileSize;
			
			double GBs = (double)(sizeInBytes) / (double)(1024 * 1024 * 1024);
			double MBs = (double)(sizeInBytes) / (double)(1024 * 1024);
			double KBs = (double)(sizeInBytes) / (double)(1024);
			
			if(GBs >= 1.0)
			{
				NSString *temp = [nf stringFromNumber:[NSNumber numberWithDouble:GBs]];
				fileSize = [NSString stringWithFormat:@"%@ GB", temp];
			}
			else if(MBs >= 1.0)
			{
				NSString *temp = [nf stringFromNumber:[NSNumber numberWithDouble:MBs]];
				fileSize = [NSString stringWithFormat:@"%@ MB", temp];
			}
			else
			{
				NSString *temp = [nf stringFromNumber:[NSNumber numberWithDouble:KBs]];
				fileSize = [NSString stringWithFormat:@"%@ KB", temp];
			}
			
			NSString *fileLink = [NSString stringWithFormat:@"<a href='http://%@%@/%@'>%@</a>",[request headerField:@"Host"], path, logFileInfo.fileName,logFileInfo.fileName];
			
			[response appendFormat:@"<tr><td>%@</td><td>%@</td><td align='right'>%@</td>", fileLink, fileDate, fileSize];
			[logFileInfo release];
		}
		else if (isSubDirectory)
		{
			if (![subDirectories objectForKey:[[file pathComponents] objectAtIndex:0]])
			{
				NSString *zipLink = [NSString stringWithFormat:@"<a href='http://%@/?zipfile=%@/%@'>Download Zip</a>",[request headerField:@"Host"], path,[[file pathComponents] objectAtIndex:0]];
				NSString *fileLink = [NSString stringWithFormat:@"<a href='http://%@%@/%@'>%@</a>", [request headerField:@"Host"],path, [[file pathComponents] objectAtIndex:0],[[file pathComponents] objectAtIndex:0]];
				
				[response appendFormat:@"<tr><td>%@</td><td>&nbsp;</td><td align='right'>%@</td>", fileLink,zipLink];
				[subDirectories setObject:[[file pathComponents] objectAtIndex:0] forKey:[[file pathComponents] objectAtIndex:0]];
			}
		}
	}
	[subDirectories release];
	if (enumerator == nil)
	{
		return nil;
	}
	[response appendString:@"</table></body></html>"];
	
	return [response dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSObject<HTTPResponse> *)openFileAt:(NSString *)path
{
	NSString *filePath = [self filePathForURI:[path stringByReplacingOccurrencesOfString:@"/Documents" withString:@""] allowDirectory:NO];
	
	BOOL isDir = NO;
	
	if (filePath && [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir] && !isDir)
	{
		return [[[HTTPFileResponse alloc] initWithFilePath:filePath forConnection:self] autorelease];
		
		// Use me instead for asynchronous file IO.
		// Generally better for larger files.
		
		//	return [[[HTTPAsyncFileResponse alloc] initWithFilePath:filePath forConnection:self] autorelease];
	}
	
	return nil;
}

-(void)openEachFileAt:(NSString*)path
{
	NSString* file;
	NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
	while (file = [enumerator nextObject])
	{
		// check if it's a directory
		BOOL isDirectory = NO;
		[[NSFileManager defaultManager] fileExistsAtPath: [NSString stringWithFormat:@"%@/%@",path,file]
											 isDirectory:&isDirectory];
		if (!isDirectory)
		{
			// open your file …
//			DDLogFileInfo *fileInfo = [DDLogFileInfo logFileWithPath:[NSString stringWithFormat:@"%@/%@",path,file]];
		}
		else
		{
			[self openEachFileAt:file];
		}
	}
}
- (NSString *)filePathForURI:(NSString *)path
{
	if ([path hasPrefix:@"/logs/"])
	{
		NSString *logsDir = [[self getLoggerManager] logsDirectory];
		return [logsDir stringByAppendingPathComponent:[path lastPathComponent]];
	}
	
	return [super filePathForURI:path];
}

- (NSString *)wsLocation
{
	NSString *port = [NSString stringWithFormat:@"%hu", [asyncSocket localPort]];
	
	NSString *wsLocation;
	NSString *wsHost = [request headerField:@"Host"];
	
	if (wsHost == nil)
	{
		wsLocation = [NSString stringWithFormat:@"ws://localhost:%@/livelog", port];
	}
	else
	{
		wsLocation = [NSString stringWithFormat:@"ws://%@/livelog", wsHost];
	}
	
	return wsLocation;
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	if ([path isEqualToString:@"/logs.html"])
	{
		NSData *indexData = [self generateIndexData];
		return [[[HTTPDataResponse alloc] initWithData:indexData] autorelease];
	}
	else if ([path isEqualToString:@"/socket.html"])
	{
		// The socket.html file contains a URL template that needs to be completed:
		// 
		// ws = new WebSocket("%%WEBSOCKET_URL%%");
		// 
		// We need to replace "%%WEBSOCKET_URL%%" with whatever URL the server is running on.
		// We can accomplish this easily with the HTTPDynamicFileResponse class,
		// which takes a dictionary of replacement key-value pairs,
		// and performs replacements on the fly as it uploads the file.
		
		NSString *loc = [self wsLocation];
		NSDictionary *replacementDict = [NSDictionary dictionaryWithObject:loc forKey:@"WEBSOCKET_URL"];
		
		return [[[HTTPDynamicFileResponse alloc] initWithFilePath:[self filePathForURI:path]
		                                            forConnection:self
		                                                separator:@"%%"
		                                    replacementDictionary:replacementDict] autorelease];
	}
	else if ([path isEqualToString:@"/documents.html"])
	{
		NSData *docData = [self generateDocumentsDirectoryData:@"/Documents"];
		return [[[HTTPDataResponse alloc] initWithData:docData] autorelease];
	}
	else if ([path hasPrefix:@"/Documents/"])
	{
		// Iterate through sub-directory of Documents directory?
		NSData *docData = [self generateDocumentsDirectoryData:path];
		if (docData == nil)
		{
			return [self openFileAt:path];
		}
		return [[[HTTPDataResponse alloc] initWithData:docData] autorelease];
	}
	else if ([path hasPrefix:@"/loglevel"])
	{
		NSMutableString *response = [NSMutableString stringWithCapacity:1000];
		NSCharacterSet* nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
		int value = [[path stringByTrimmingCharactersInSet:nonDigits] intValue];
		NSString *logLevel =nil;
		if (value <0)
		{
			value= LOG_LEVEL_OFF;
		}
		switch (value) {
			case LOG_LEVEL_OFF:
				logLevel = @"turned off";
				break;
			case LOG_LEVEL_ERROR:
				logLevel = @"Error only";
				break;
			case LOG_LEVEL_WARN:
				logLevel = @"Errors and warnings";
				break;
			case LOG_LEVEL_INFO:
				logLevel = @"Errors, warnings and information";
				break;
			case LOG_LEVEL_VERBOSE:
				logLevel = @"Errors, warnings, information and verbose";
				break;
			default:
				logLevel = @"Custom value with a 'Logical OR' of current log level and that of supplied one";
				break;
		}
		NSString *definitions = @"<br />LOG_LEVEL_OFF :0<br />LOG_LEVEL_ERROR:1 (0...0001)<br />LOG_LEVEL_WARN:3 (0...0011)<br />LOG_LEVEL_INFO:7 (0...0111)<br />LOG_LEVEL_VERBOSE:15 (0...1111)<br />";
		[response appendString:@"<html><head>"];
		[response appendString:@"<style type='text/css'>@import url('styles.css');</style>"];
		[response appendString:@"</head><body><div>"];
		[response appendString: [NSString stringWithFormat:@"The Log level has been reset to :%@. <br />Following are the definitions:%@",logLevel,definitions]];
		[response appendString:@"</div></body></html>"];
		NSData *data =[response dataUsingEncoding:NSUTF8StringEncoding];
		NSDictionary *userinfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithInt: value], @"ddloglevel",
								  nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ddloglevel"
															object:nil userInfo:userinfo];
		return [[[HTTPDataResponse alloc] initWithData:data] autorelease];
	}
	else if ([path hasPrefix:@"/?zipfile"])
	{
		NSString *zipPath=[[[request url] relativeString] stringByReplacingOccurrencesOfString:@"/?zipfile=" withString:@""];
		NSString *zipFullPath = [NSString stringWithFormat:@"%@%@/",[config.documentRoot stringByReplacingOccurrencesOfString:@"/Documents" withString:@""],zipPath];
		NSLog(@"zipfile:%@",zipFullPath);
		Objective_Zipper *zipper =[[Objective_Zipper alloc] init];
		NSData *data =[zipper zip:zipFullPath];
		[zipper release];
		return [[[HTTPDataResponse alloc] initWithData:data] autorelease];
	}
	else
	{
		return [super httpResponseForMethod:method URI:path];
	}
}

- (WebSocket *)webSocketForURI:(NSString *)path
{
	if ([path isEqualToString:@"/livelog"])
	{
		// Create the WebSocket
		WebSocket *ws = [[WebSocket alloc] initWithRequest:request socket:asyncSocket];
		
		// Create the WebSocketLogger
//		WebSocketLogger *wsLogger = [[WebSocketLogger alloc] initWithWebSocket:ws];
		
		// Memory management:
		// The WebSocket will be retained by the HTTPServer and the WebSocketLogger.
		// The WebSocketLogger will be retained by the logging framework,
		// as it adds itself to the list of active loggers from within its init method.
		
//		[wsLogger release];
		return [ws autorelease];
	}
	
	return [super webSocketForURI:path];
}

@end