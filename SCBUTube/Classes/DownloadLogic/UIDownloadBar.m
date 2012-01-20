

#import "UIDownloadBar.h"


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
possibleFilename;

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


- (void) forceStop {
	operationBreaked = YES;
	inProgress=NO;
}

- (void) pauseDownload
{
	[self forceStop];
	[self saveDownloadInfo:@"PausedDownloads" bytesReceived:bytesReceived createMainFile:YES];
	
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
		if (percentComplete !=100)
		{
			//[self saveDownloadInfo];
		}
		else
		{
			inProgress =NO;
			[self deleteSavedState];
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
	inProgress =NO;
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
	[self saveDownloadInfo:@"Succeeded" bytesReceived:0 createMainFile:NO];
	[self.delegate downloadBar:self didFinishWithData:self.receivedData suggestedFilename:self.possibleFilename];
	operationFinished = YES;
	NSLog(@"Connection did finish loading...");
	//[connection release];
}

//- (void)drawRect:(CGRect)rect {
//	[super drawRect:rect];
//}

- (void)dealloc {
	[possibleFilename release];
	[receivedData release];
	[DownloadRequest release];
//	[DownloadConnection release];
	[super dealloc];
}

@end
