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
#import "DDNumber.h"
//#import "WebSocketLogger.h"

#import <UIKit/UIKit.h>

#import "Objective_Zipper.h"
#define BARRED_FILE_EXTENSIONS @"|.css|.js|.png|.html|.state|.DS_Store|"

@implementation WebHTTPConnection

@synthesize logFileManager;
@synthesize fileLogger;
@synthesize possibleFilename;

-(id <DDLogFileManager>) getLoggerManager
{
    if (self.logFileManager == nil)
    {
		// Check if the UIApplicationDelegate has a fileLogger
		if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(fileLogger)])
		{
			return [[[[UIApplication sharedApplication] delegate] performSelector:@selector(fileLogger)] logFileManager];
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
			// It's a file
			if ([BARRED_FILE_EXTENSIONS rangeOfString:[[file lowercaseString] pathExtension]].location ==NSNotFound)
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
		}
		else if (isSubDirectory)
		{
			if (![subDirectories objectForKey:[[file pathComponents] objectAtIndex:0]])
			{
				NSString *zipLink = [NSString stringWithFormat:@"<a href='http://%@/?zipfile=%@/%@'>Download Zip</a>",[request headerField:@"Host"], path,[[file pathComponents] objectAtIndex:0]];
				NSString *fileLink = [NSString stringWithFormat:@"<a href='http://%@%@/%@'>%@</a>", [request headerField:@"Host"],path, [[file pathComponents] objectAtIndex:0],[[[file pathComponents] objectAtIndex:0] stringByDeletingPathExtension]];
				
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
	if ([self supportsPOST:path withSize:0])
	{
		[response appendString:@"<form action=\"post.html\" method=\"post\" enctype=\"multipart/form-data\" name=\"form1\" id=\"form1\">"];
		[response appendString:@"<label>&nbsp;&nbsp;&nbsp;&nbsp;Upload file:"];
		[response appendString:@"<input type=\"file\" name=\"file\" id=\"file\" />"];
		[response appendString:@"</label>"];
		[response appendString:@"<label>"];
		[response appendString:@"<input type=\"submit\" name=\"button\" id=\"button\" value=\"Upload\" />"];
		[response appendString:@"</label>"];
		[response appendString:@"</form>"];
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
//	NSLog(@"postContentLength: %qu", requestContentLength);
//	NSLog(@"postTotalBytesReceived: %qu", requestContentLengthReceived);
	
	if([method isEqualToString:@"POST"])
	{
////		NSLog(@"request: %@", request);
//		NSString *postStr = nil;
//		
//		NSData *postData = [request body];
//		if(postData)
//		{
//			postStr = [[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding] autorelease];
//		}
//		
////		NSLog(@"postStr: %@", postStr);
//		
//		// Result will be of the form "answer=..."
//		
//		int answer = [[postStr substringFromIndex:7] intValue];
//		
//		NSData *response = nil;
//		if(answer == 10)
//		{
//			response = [@"<html><body>Correct<body></html>" dataUsingEncoding:NSUTF8StringEncoding];
//		}
//		else
//		{
//			response = [@"<html><body>Sorry - Try Again<body></html>" dataUsingEncoding:NSUTF8StringEncoding];
//		}
		
		return [self handlePostedDataForMethod:method URI:path];
//		return [[[HTTPDataResponse alloc] initWithData:response] autorelease];
	}
	else if ([path isEqualToString:@"/logs.html"])
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

/**
 * Overrides HTTPConnection's method
 **/
- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
	// Add support for POST
	
	if([method isEqualToString:@"POST"])
	{
		if([path isEqualToString:@"/post.html"])
		{
			// Let's be extra cautious, and make sure the upload isn't 5 gigs
			
			BOOL result = NO;
			
			NSString *contentLengthStr = [request headerField:@"Content-Length"];
			
			UInt64 contentLength;
			if([NSNumber parseString:(NSString *)contentLengthStr intoUInt64:&contentLength])
			{
				result = contentLength < 1024*1024*1024;
			}
			
//			if(contentLengthStr) CFRelease(contentLengthStr);
			return result;
		}
	}
	
	return [super supportsMethod:method atPath:path];
}

/**
 * Overrides HTTPConnection's method
 **/
- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)relativePath
{
	// Inform HTTP server that we expect a body to accompany a POST request
	
	if([method isEqualToString:@"POST"])
		return YES;
	
	return [super expectsRequestBodyFromMethod:method atPath:relativePath];
}


/**
 * This method is called after receiving all HTTP headers, but before reading any of the request body.
 **/
//- (void)prepareForBodyWithSize:(UInt64)contentLength
//{
//	// Override me to allocate buffers, file handles, etc.
//	NSLog(@"request headers:%@",[request allHeaderFields]);
////	NSFileManager *fileManager = [NSFileManager defaultManager];
////	
////	NSArray *components = [self.possibleFilename componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
////	self.possibleFilename = [components componentsJoinedByString:@" "];
////	if (createMainFile)
////	{
////		NSString *pausedFile =[NSString stringWithFormat:@"%@/%@/%@.paused", [paths objectAtIndex:0],inDirectory,self.possibleFilename];
////		[fileManager createFileAtPath:pausedFile contents:self.receivedData attributes:nil];
////	}
//	[super prepareForBodyWithSize:contentLength];
//}

/**
 * This method is called to handle data read from a POST / PUT.
 * The given data is part of the request body.
 **/
- (void)processBodyData:(NSData *)postDataChunk
{
	// Override me to do something useful with a POST / PUT.
	// If the post is small, such as a simple form, you may want to simply append the data to the request.
	// If the post is big, such as a file upload, you may want to store the file to disk.
	// 
	// Remember: In order to support LARGE POST uploads, the data is read in chunks.
	// This prevents a 50 MB upload from being stored in RAM.
	// The size of the chunks are limited by the POST_CHUNKSIZE definition.
	// Therefore, this method may be called multiple times for the same POST request.
//	BOOL result = [request appendData:postDataChunk];
//	
//	if(!result)
//	{
//		NSLog(@"Couldn't append bytes!");
//	}
	if (!postHeaderOK)
	{
		UInt16 separatorBytes = 0x0A0D;
		NSData* separatorData = [NSData dataWithBytes:&separatorBytes length:2];
		
		int l = [separatorData length];
		
		for (int i = 0; i < [postDataChunk length] - l; i++)
		{
			NSRange searchRange = {i, l};
			
			if ([[postDataChunk subdataWithRange:searchRange] isEqualToData:separatorData])
			{
				NSRange newDataRange = {dataStartIndex, i - dataStartIndex};
				dataStartIndex = i + l;
				i += l - 1;
				NSData *newData = [postDataChunk subdataWithRange:newDataRange];
				
				if ([newData length])
				{
					[multipartData addObject:newData];
				}
				else
				{
					postHeaderOK = TRUE;
					
					NSString* postInfo = [[NSString alloc] initWithBytes:[[multipartData objectAtIndex:1] bytes] length:[[multipartData objectAtIndex:1] length] encoding:NSUTF8StringEncoding];
					NSLog(@"postInfo:%@",postInfo);
					NSArray* postInfoComponents = [postInfo componentsSeparatedByString:@"; filename="];
					postInfoComponents = [[postInfoComponents lastObject] componentsSeparatedByString:@"\""];
					postInfoComponents = [[postInfoComponents objectAtIndex:1] componentsSeparatedByString:@"\\"];
					NSString* filename = [[config.server documentRoot] stringByAppendingPathComponent:[postInfoComponents lastObject]];
					NSRange fileDataRange = {dataStartIndex, [postDataChunk length] - dataStartIndex};
					
					if ([[[postInfoComponents lastObject] pathExtension] isEqualToString:@"attrib"])
					{
						filename = [[config.server documentRoot] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",@"PausedDownloads",[postInfoComponents lastObject]]];
					}
					[[NSFileManager defaultManager] createFileAtPath:filename contents:[postDataChunk subdataWithRange:fileDataRange] attributes:nil];
					NSFileHandle *file = [[NSFileHandle fileHandleForUpdatingAtPath:filename] retain];
					
					if (file)
					{
						[file seekToEndOfFile];
						[multipartData addObject:file];
					}
					
					[postInfo release];
					
					break;
				}
			}
		}
	}
	else
	{
		NSFileHandle* fh = (NSFileHandle*)[multipartData lastObject];
		if (fh) {
			[fh writeData:postDataChunk];
		}
		
	}
//	[super processBodyData:postDataChunk];
}

/**
 * This method is called after the request body has been fully read but before the HTTP request is processed.
 **/
//- (void)finishBody
//{
//	// Override me to perform any final operations on an upload.
//	// For example, if you were saving the upload to disk this would be
//	// the hook to flush any pending data to disk and maybe close the file.
//	[super finishBody];
//}

-(NSObject<HTTPResponse> *)handlePostedDataForMethod:(NSString *)method URI:(NSString *)path
{
	NSLog(@"httpResponseForURI: method:%@ path:%@", method, path);
	
	NSData *requestData = [request messageData];
	
	NSString *requestStr = [[[NSString alloc] initWithData:requestData encoding:NSASCIIStringEncoding] autorelease];
	NSLog(@"\n=== Request ====================\n%@\n================================", requestStr);
	
	if (requestContentLength > 0)  // Process POST data
	{
		NSLog(@"processing post data: %qu", requestContentLength);
		
		if ([multipartData count] < 2) return nil;
		
		NSString* postInfo = [[NSString alloc] initWithBytes:[[multipartData objectAtIndex:1] bytes]
													  length:[[multipartData objectAtIndex:1] length]
													encoding:NSUTF8StringEncoding];
		
		NSArray* postInfoComponents = [postInfo componentsSeparatedByString:@"; filename="];
		postInfoComponents = [[postInfoComponents lastObject] componentsSeparatedByString:@"\""];
		postInfoComponents = [[postInfoComponents objectAtIndex:1] componentsSeparatedByString:@"\\"];
		NSString* filename = [postInfoComponents lastObject];
		
		if (![filename isEqualToString:@""]) //this makes sure we did not submitted upload form without selecting file
		{
			UInt16 separatorBytes = 0x0A0D;
			NSMutableData* separatorData = [NSMutableData dataWithBytes:&separatorBytes length:2];
			[separatorData appendData:[multipartData objectAtIndex:0]];
			int l = [separatorData length];
			int count = 2;	//number of times the separator shows up at the end of file data
			
			NSFileHandle* dataToTrim = [multipartData lastObject];
			NSLog(@"data: %@", dataToTrim);
			
			for (unsigned long long i = [dataToTrim offsetInFile] - l; i > 0; i--)
			{
				[dataToTrim seekToFileOffset:i];
				if ([[dataToTrim readDataOfLength:l] isEqualToData:separatorData])
				{
					[dataToTrim truncateFileAtOffset:i];
					i -= l;
					if (--count == 0) break;
				}
			}
			
			NSLog(@"NewFileUploaded");
			[[NSNotificationCenter defaultCenter] postNotificationName:@"NewFileUploaded" object:nil];
		}
		
		for (int n = 1; n < [multipartData count] - 1; n++)
			NSLog(@"%@", [[NSString alloc] initWithBytes:[[multipartData objectAtIndex:n] bytes] length:[[multipartData objectAtIndex:n] length] encoding:NSUTF8StringEncoding]);
		
		[postInfo release];
		[multipartData release];
		requestContentLength = 0;
		
	}
	
//	NSString *filePath = [self filePathForURI:path];
	NSString *folder = @"/Documents";//[path isEqualToString:@"/"] ? [config.server documentRoot]: [NSString stringWithFormat: @"%@%@", [config.server documentRoot], path];
	
	if ([self isBrowseable:folder])
	{
		NSLog(@"folder: %@", folder);
		NSData *docData = [self generateDocumentsDirectoryData:folder];
		return [[[HTTPDataResponse alloc] initWithData:docData] autorelease];
	}
	
	return nil;
}
/**
 * Returns whether or not the server will accept POSTs.
 * That is, whether the server will accept uploaded data for the given URI.
 **/
- (BOOL)supportsPOST:(NSString *)path withSize:(UInt64)contentLength
{
	//	NSLog(@"POST:%@", path);
	
	dataStartIndex = 0;
	multipartData = [[NSMutableArray alloc] init];
	postHeaderOK = FALSE;
	
	return YES;
}
/**
 * Returns whether or not the requested resource is browseable.
 **/
- (BOOL)isBrowseable:(NSString *)path
{
	// Override me to provide custom configuration...
	// You can configure it for the entire server, or based on the current request
	
	return YES;
}

@end