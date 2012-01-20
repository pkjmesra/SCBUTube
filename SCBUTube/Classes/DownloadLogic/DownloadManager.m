//
//  DownloadManager.m
//  SCBUTube
//
//  Created by Praveen Jha on 12/01/12.
//  Copyright (c) 2012 . All rights reserved.
//

#import "DownloadManager.h"

@implementation DownloadManager

@synthesize queue;
@synthesize delegate;

/*
//TODO:
 1.	Create an adhoc network using gamekit over bluetooth
	When a user connects to you, load a navigation controller with "Movies"
	Send a list of all MP4 files.Let the user select an MP4 and play MP4 on his device.
 2.	Create a downloadable zip on request from browser.
 3.	Upload the zip file or the .attrib file to have export/import feature.
 4.	Live stream.
 5.	App settings.
 6.	YouTube sections like YouTube App.
 7.	Go forward for webview.
 8.	Share video download link over email. 
 9.	Create WiFi hotspot, http live stream to other devices over browser.
//
 */
- (DownloadManager *)init {
	self = [super init];
	if(self) {
		queue = [[NSMutableArray alloc] initWithCapacity:0];
		isIdle =YES;
		[self loadQueuedOrPausedItems];
	}
	return self;
}

-(void)loadQueuedOrPausedItems
{
	// Save the data received so far into a file
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *pausedDir = [NSString stringWithFormat:@"%@/PausedDownloads", [paths objectAtIndex:0]];
	
	NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:pausedDir error:nil];
	NSArray *attribs = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.attrib'"]];
	
	// Now that we have the paused download file details, let's add them into queue
	for (NSString *filePath in attribs) 
	{
		NSLog(@"Added into Queue the File:%@",[filePath lastPathComponent]);
		NSEnumerator *fileEnum=[[[[[NSString alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",pausedDir, filePath] encoding:NSUTF8StringEncoding error:nil] autorelease]
							 componentsSeparatedByString:@"\n"] objectEnumerator];
		NSString *line;
		
		DownloadInfo *pausedInfo = [[DownloadInfo alloc] init];
		NSString *title;
		NSString *url;
		long long expectedBytes=0;
		float bytesReceived=0;
		
		while(line = [fileEnum nextObject]) 
		{
			NSLog(@"line:%@",line);
			if ([line hasPrefix:@"Title="])
			{
				title =[[line substringFromIndex:6] stringByReplacingOccurrencesOfString:@"\n" withString:@""]; 
			}
			else if ([line hasPrefix:@"URL="])
			{
				url =[[line substringFromIndex:4] stringByReplacingOccurrencesOfString:@"\n" withString:@""]; 
			}
			else if ([line hasPrefix:@"ExpectedBytes="])
			{
				NSScanner *scanner1 = [NSScanner scannerWithString:[[line substringFromIndex:14] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
				[scanner1 scanLongLong:&expectedBytes];
			}
			else if ([line hasPrefix:@"BytesReceived="])
			{
				NSScanner *scanner2 = [NSScanner scannerWithString:[[line substringFromIndex:14] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
				[scanner2 scanFloat:&bytesReceived];			}
		}
		[pausedInfo setObject:url forKey:title];
		[pausedInfo setUpWithPausedDownload:expectedBytes ReceivedBytes:bytesReceived];
		[self addNewDownloadItem:pausedInfo];
		[pausedInfo release];
	}

}

-(void)addNewDownloadItem:(DownloadInfo *)item
{
	[self.queue addObject:item];
	item.delegate = self;
}

-(void) start
{
	if (self.queue.count >0)
	{
		if (isIdle)
		{
			isIdle =NO;
			DownloadInfo *newDownload =[self.queue objectAtIndex:0];
			if (!newDownload.operationCompleted)
			{
				if (newDownload.bar ==nil)
				{
					[newDownload setUp:NO];
				}
//				newDownload.delegate =self;
				[newDownload beginDownload];
			}
		}			
	}
	else
		isIdle =YES;
}

-(void) pause
{
	// Pause all downloads so that user can restart the downloads next 
	// time the network is connected
	isIdle = NO; //reset the flag so no new download starts
	for (DownloadInfo *dInfo in self.queue) {
		[dInfo pauseDownload];
	}
	isIdle = YES;
}

- (void) continueDownload
{
	// Read all files from PausedDownloads directory and restart the downloads
	// after adding them into the queue
	
	isIdle = NO; //reset the flag so no new download starts
	for (DownloadInfo *dInfo in self.queue)
	{
		dInfo.delegate =self;
		[dInfo beginDownload];
	}

}

-(void) forceStop
{

}

-(void) forceContinue
{
	
}

- (void)downloadDidFinish:(DownloadInfo *)info
{
	[self.queue removeObject:info];
	info =nil;
	[self.delegate downloadManagerDidFinish:info];
	isIdle =YES;
	[self start];
}

- (void)downloadInfo:(DownloadInfo *)info didFailWithError:(NSError *)error 
{
	[self.delegate downloadManagerInfo:info didFailWithError:error];
}

- (void)downloadUpdated:(DownloadInfo *)info 
{
	[self.delegate downloadManagerUpdated:info];
}

- (void)downloadPaused:(DownloadInfo *)info forFile:(NSString *)filename
{
	[self.delegate downloadManagerPaused:info forFile:filename];
}
- (void)downloadReStarted:(DownloadInfo *)info forFile:(NSString *)filename
{
	[self.delegate downloadManagerReStarted:info forFile:filename];
}

- (void)downloadDropped:(DownloadInfo *)info forFile:(NSString *)filename
{
	[self.queue removeObject:info];
	info =nil;
	isIdle =YES;
	[self.delegate downloadManagerDropped:info forFile:filename];
//	[self start];
}

- (void)dealloc {
	[queue release];
	queue=nil;
	delegate =nil;
	[super dealloc];
}
@end
