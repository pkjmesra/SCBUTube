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

#import "UIDownloadBar.h"

//TODO: check when the download fails with error:-1004, description:Could not connect to the server.
// try again loading the original YT link and parsing the current url and trying to download 
// again with current url

@implementation UIDownloadBar

@synthesize DownloadRequest,
DownloadConnection,
receivedData,
expectedBytes,
bytesReceived,
delegate,
percentComplete,
operationIsOK,
operationBreaked,
appendIfExist,
downloadUrl,
inProgress,
operationFailed,
//fileUrlPath,
possibleFilename,
orgYTLink;

-(void)saveDownloadInfo:(NSString *)inDirectory 
		  bytesReceived:(float)rcvdBytes 
		 createMainFile:(BOOL)createMainFile
{
	// Save the data received so far into a file
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	[fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0],inDirectory] withIntermediateDirectories:YES attributes:nil error:nil];
	
	NSArray *components = [self.possibleFilename componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
	self.possibleFilename = [components componentsJoinedByString:@" "];
	if (createMainFile)
	{
		NSString *pausedFile =[NSString stringWithFormat:@"%@/%@/%@.paused", [paths objectAtIndex:0],inDirectory,self.possibleFilename];
		[fileManager createFileAtPath:pausedFile contents:self.receivedData attributes:nil];
	}
	NSString *attributes = [NSString stringWithFormat:@"Title=%@\nURL=%@\nExpectedBytes= %lld\nBytesReceived=%.2f\n",
							[self.possibleFilename stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
							[[self.downloadUrl absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
							expectedBytes,
							rcvdBytes];
	
	NSString *attribFile =[NSString stringWithFormat:@"%@/%@/%@.attrib", [paths objectAtIndex:0],inDirectory,self.possibleFilename];
	[fileManager createFileAtPath:attribFile contents:[attributes dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
//	NSLog(@"pausedFile:%@, attribFile:%@",pausedFile,attribFile);

}

-(void)deleteSavedState
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *pausedFile = [NSString stringWithFormat:@"%@/PausedDownloads/%@.paused", [paths objectAtIndex:0],self.possibleFilename];
	NSString *attribFile =[NSString stringWithFormat:@"%@/PausedDownloads/%@.attrib", [paths objectAtIndex:0],self.possibleFilename];
	if([fileManager fileExistsAtPath:pausedFile isDirectory:NO])
	{
		[fileManager removeItemAtPath:pausedFile error:nil];
	}
	if([fileManager fileExistsAtPath:attribFile isDirectory:NO])
	{
		[fileManager removeItemAtPath:attribFile error:nil];
	}
}

-(void)saveCurrentDataState
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSArray *components = [self.possibleFilename componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
	self.possibleFilename = [components componentsJoinedByString:@" "];
	
	NSString *pausedFile = [NSString stringWithFormat:@"%@/PausedDownloads/%@.paused", [paths objectAtIndex:0],self.possibleFilename];
	NSString *attribFile =[NSString stringWithFormat:@"%@/PausedDownloads/%@.attrib", [paths objectAtIndex:0],self.possibleFilename];
	NSMutableData *fileData;
	if([fileManager fileExistsAtPath:pausedFile isDirectory:NO])
	{
		fileData = [NSMutableData dataWithContentsOfFile:pausedFile];
		[fileData appendData:self.receivedData];
		[fileManager removeItemAtPath:pausedFile error:nil];
	}
	else
	{
		fileData = [NSMutableData dataWithData:self.receivedData];
	}
	[fileManager createFileAtPath:pausedFile contents:fileData attributes:nil];

	NSString *attributes = [NSString stringWithFormat:@"Title=%@\nURL=%@\nExpectedBytes= %lld\nBytesReceived=%.2f\n",
							[self.possibleFilename stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
							[[self.downloadUrl absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
							expectedBytes,
							bytesReceived];
	if([fileManager fileExistsAtPath:attribFile isDirectory:NO])
	{
		[fileManager removeItemAtPath:attribFile error:nil];
	}
	[fileManager createFileAtPath:attribFile contents:[attributes dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
	fileData =nil;
}

- (void) forceStop {
	operationBreaked = YES;
	inProgress=NO;
}

- (void) pauseDownload
{
	[self forceStop];
	//[self saveDownloadInfo:@"PausedDownloads" bytesReceived:bytesReceived createMainFile:YES];
	[self saveCurrentDataState];
	if (self.delegate && [self.delegate respondsToSelector:@selector(downloadBarPaused:forFile:)])
		[self.delegate downloadBarPaused:self forFile:self.possibleFilename];
}

- (void) continueDownload
{
	operationBreaked = NO;
	if (self.delegate && [self.delegate respondsToSelector:@selector(downloadBarReStarted:forFile:)])
		[self.delegate downloadBarReStarted:self forFile:self.possibleFilename];
	[self forceContinue];
}

- (void) forceContinue {
	operationBreaked = NO;
	
	NSLog(@"Last saved bytesReceived :%.2f",bytesReceived);
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: downloadUrl];
	
	[request addValue: [NSString stringWithFormat: @"bytes=%.0f-", bytesReceived ] forHTTPHeaderField: @"Range"];	
	
	DownloadConnection = [NSURLConnection connectionWithRequest:request
												  delegate: self];	
	if(DownloadConnection == nil) 
	{
		[self.delegate downloadBar:self didFailWithError:[NSError errorWithDomain:@"UIDownloadBar Error" code:1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"NSURLConnection Failed", NSLocalizedDescriptionKey, nil]]];
	}
}


- (void)beginDownloadWithURL:(NSURL *)fileURL timeout:(NSInteger)timeout fileName:(NSString *)fileName
{
	if (self)
	{
		self.downloadUrl = fileURL;
		if (fileName != nil)
		{
			self.possibleFilename = fileName;
		}
		else
		{
			self.possibleFilename = [[fileURL absoluteString] lastPathComponent];
		}
		if (!operationBreaked)
		{
			DownloadRequest = [[NSURLRequest alloc] initWithURL:fileURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeout];
			DownloadConnection = [[NSURLConnection alloc] initWithRequest:DownloadRequest delegate:self startImmediately:YES];
					
			if(DownloadConnection == nil) 
			{
				[self.delegate downloadBar:self didFailWithError:[NSError errorWithDomain:@"UIDownloadBar Error" code:1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"NSURLConnection Failed", NSLocalizedDescriptionKey, nil]]];
			}
		}
		else
		{
			[self continueDownload];
		}
	}
}

- (UIDownloadBar *)initWithProgressBarFrame:(CGRect)frame delegate:(id<UIDownloadBarDelegate>)theDelegate
{
	self = [super initWithFrame:frame];
	if(self) 
	{
		self.delegate = theDelegate;
		bytesReceived = percentComplete = 0;
		self.progress = 0.0;
		self.backgroundColor = [UIColor clearColor];
		receivedData = [[NSMutableData alloc] initWithLength:0];
	}
	return self;
}
	
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

	if (!operationBreaked)
	{
		inProgress =YES;
		[self.receivedData appendData:data];
		
		float receivedLen = [data length];
		bytesReceived = (bytesReceived + receivedLen);
		
		if(expectedBytes != NSURLResponseUnknownLength) {
			self.progress = ((bytesReceived/(float)expectedBytes)*100)/100;
			percentComplete = self.progress*100;
		}
			//NSLog(@" Data receiving... Percent complete: %f", percentComplete);
		if (percentComplete ==100)
		{
			inProgress =NO;
		}
		// Save state if memory consumption is more than 4MB or download is completed
		if (([self.receivedData length]>=4194304) || (percentComplete ==100))
		{
			[self saveCurrentDataState];
			[receivedData release];
			receivedData =nil;
			if (percentComplete !=100)
				receivedData = [[NSMutableData alloc] initWithLength:0];
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(downloadBarUpdated:)])
		[self.delegate downloadBarUpdated:self];
	
	} 
	else 
	{
		inProgress =NO;
		[connection cancel];
		NSLog(@" STOP !!!!  Receiving data was stopped");
	}
		
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"error:%d, description:%@",[error code],[error localizedDescription]);
	inProgress =NO;
	[receivedData release];
	[self saveDownloadInfo:@"Failed" bytesReceived:0 createMainFile:NO];
	[self.delegate downloadBar:self didFailWithError:error];
	operationFailed = YES;
	[connection release];
}

//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//	expectedBytes = [response expectedContentLength];
//	NSLog(@"DID RECEIVE RESPONSE");
//}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
	
//	NSLog(@"[DO::didReceiveData] %d operation", (int)self);
//	NSLog(@"[DO::didReceiveData] ddb: %.2f, wdb: %.2f, ratio: %.2f", 
//		  (float)bytesReceived, 
//		  (float)expectedBytes,
//		  (float)bytesReceived / (float)expectedBytes);
	
	NSHTTPURLResponse *r = (NSHTTPURLResponse*) response;
	NSDictionary *headers = [r allHeaderFields];
//	NSLog(@"[DO::didReceiveResponse] response headers: %@", headers);
	if (headers)
	{
		if ([headers objectForKey: @"Content-Range"]) 
		{
			NSString *contentRange = [headers objectForKey: @"Content-Range"];
			NSLog(@"Content-Range: %@", contentRange);
			NSRange range = [contentRange rangeOfString: @"/"];
			NSString *totalBytesCount = [contentRange substringFromIndex: range.location + 1];
			expectedBytes = [totalBytesCount floatValue];
		} 
		else if ([headers objectForKey: @"Content-Length"]) 
		{
			NSLog(@"Content-Length: %@", [headers objectForKey: @"Content-Length"]);
			expectedBytes = [[headers objectForKey: @"Content-Length"] floatValue];
		} 
		else expectedBytes = -1;
		
		if ([@"Identity" isEqualToString: [headers objectForKey: @"Transfer-Encoding"]]) 
		{
			expectedBytes = bytesReceived;
			operationFinished = YES;
		}
		
		// Check if proxy denied access
		if ([headers objectForKey: @"Content-Type"]) 
		{
			NSLog(@"Content-Type: %@", [headers objectForKey: @"Content-Type"]);
			NSString *contentType = [headers objectForKey: @"Content-Type"];
			if ([contentType isEqualToString:@"text/html"])
			{
				operationBreaked=YES;
				operationFailed=YES;
				inProgress =NO;
				expectedBytes=0; //reset so we know we'll need to find the correct value later
				[self saveDownloadInfo:@"Failed" bytesReceived:0 createMainFile:NO];
				[self saveDownloadInfo:@"PausedDownloads" bytesReceived:bytesReceived createMainFile:YES];
				[self.delegate downloadBar:self didFailWithError:nil];
				self.possibleFilename = nil;
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SCBUTube" message:@"Your Proxy denied access to video." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alertView show];
                [alertView release];
				return;
			}
		}
		inProgress =YES;
		[self saveDownloadInfo:@"All" bytesReceived:0 createMainFile:NO];
	}		
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	inProgress =NO;
	NSFileManager *fileManager =[NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	[self saveDownloadInfo:@"Succeeded" bytesReceived:0 createMainFile:NO];
	NSString *pausedFile = [NSString stringWithFormat:@"%@/PausedDownloads/%@.paused", [paths objectAtIndex:0],self.possibleFilename];
	NSMutableData *fileData;
	if([fileManager fileExistsAtPath:pausedFile isDirectory:NO])
	{
		fileData = [NSMutableData dataWithContentsOfFile:pausedFile];
//		[fileData appendData:self.receivedData];
		[fileManager removeItemAtPath:pausedFile error:nil];
	}
	else
	{
		fileData = [NSMutableData dataWithData:self.receivedData];
	}
	operationFinished = YES;
	[self.delegate downloadBar:self didFinishWithData:fileData suggestedFilename:self.possibleFilename];
	[self deleteSavedState];
//	[receivedData release];

	NSLog(@"Connection did finish loading...");
	//[connection release];
}

//- (void)drawRect:(CGRect)rect {
//	[super drawRect:rect];
//}

- (void)dealloc {
	[possibleFilename release];
//	[receivedData release];
	[DownloadRequest release];
//	[DownloadConnection release];
	[super dealloc];
}

@end
