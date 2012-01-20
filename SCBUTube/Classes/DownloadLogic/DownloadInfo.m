//
//  DownloadInfo.m
//  SCBUTube
//
//  Created by Praveen Jha on 12/01/12.
//  Copyright (c) 2012 . All rights reserved.
//

#import "DownloadInfo.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>

@implementation DownloadInfo

@synthesize percentComplete;
@synthesize delegate;
@synthesize bar;
@synthesize operationCompleted;

- (DownloadInfo *)init {
	self = [super init];
	if(self) {
	}
	return self;
}

- (void)setObject:(id)anObject forKey:(id)aKey
{
	key = [aKey retain];
	value = [anObject retain];
}

- (NSUInteger)count
{
	return 1;
}

-(NSString *) FileTitle
{
	return key;
}

-(NSString *) FileUrl
{
	return value;
}

-(void)saveDownloadInfo
{
	// Save the data received so far into a file
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	[fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/PausedDownloads", [paths objectAtIndex:0]] withIntermediateDirectories:YES attributes:nil error:nil];
	
	NSString *localFilename =[self FileTitle];
	NSArray *components = [localFilename componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
	localFilename = [components componentsJoinedByString:@" "];
	
	NSString *pausedFile =[NSString stringWithFormat:@"%@/PausedDownloads/%@.paused", [paths objectAtIndex:0],localFilename];
	[fileManager createFileAtPath:pausedFile contents:[[NSString stringWithString:@""] dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
	NSString *attributes = [NSString stringWithFormat:@"Title=%@\nURL=%@\nExpectedBytes= %lld\nBytesReceived=%.2f\n",
							[localFilename stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
							[[self FileUrl] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
							0,
							0];
	
	NSString *attribFile =[NSString stringWithFormat:@"%@/PausedDownloads/%@.attrib", [paths objectAtIndex:0],localFilename];
	[fileManager createFileAtPath:attribFile contents:[attributes dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
	NSLog(@"Added into Queue the File:%@, attribFile:%@",pausedFile,attribFile);
	
}

-(BOOL)setUp:(BOOL)startImmediate
{
	[self saveDownloadInfo];
	if (startImmediate)
	{
		bar = [[UIDownloadBar alloc] initWithProgressBarFrame:CGRectMake(0, 17.0, 50, 11.0)
									delegate:self];
	
		[bar setProgressViewStyle:UIProgressViewStyleBar];
		[bar beginDownloadWithURL:[NSURL URLWithString:[self FileUrl]] timeout:600 fileName:[self FileTitle]];
	}
	else
	{
		bar = [[UIDownloadBar alloc] initWithProgressBarFrame:CGRectMake(140.0, 36.0, 130.0, 11.0)
													 delegate:self];
		
		[bar setProgressViewStyle:UIProgressViewStyleDefault];
	}
	return YES;
}

-(void)setUpWithPausedDownload:(long long)expectedBytes ReceivedBytes:(float)bytesReceived
{
	bar = [[UIDownloadBar alloc] initWithProgressBarFrame:CGRectMake(140.0, 36, 130.0, 11.0)
												 delegate:self];
	
	[bar setProgressViewStyle:UIProgressViewStyleDefault];
	bar.expectedBytes = expectedBytes;
	bar.bytesReceived = bytesReceived;
	if (expectedBytes >0) // The download was indeed paused rather than just queued in which case it should have been 0
	{
		[bar forceStop];
		// Read the contents of file into the receivedData
//		bar.receivedData = [self loadQueuedOrPausedItemContents];
		bar.progress = ((bytesReceived/(float)expectedBytes)*100)/100;
	}
}

-(NSMutableData *)loadQueuedOrPausedItemContents
{
	// Save the data received so far into a file
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *pausedFile = [NSString stringWithFormat:@"%@/PausedDownloads/%@.paused", [paths objectAtIndex:0],[self FileTitle]];
	if([fileManager fileExistsAtPath:pausedFile isDirectory:NO])
	{
		return [NSMutableData dataWithContentsOfFile:pausedFile];
	}
	return [[NSMutableData alloc] initWithLength:0];
}

-(void)beginDownload
{
	[bar beginDownloadWithURL:[NSURL URLWithString:[self FileUrl]] timeout:600 fileName:[self FileTitle]];
}

-(void)dropDownload
{
	if (![bar.possibleFilename length])
	{
		bar.possibleFilename =[self FileTitle];
	}
	if (!bar.downloadUrl)
	{
		bar.downloadUrl =[NSURL URLWithString:[self FileUrl]];
	}
	[bar forceStop];
	[bar saveDownloadInfo:@"Dropped" bytesReceived:0 createMainFile:NO];
	[bar deleteSavedState];
	[self.delegate downloadDropped:self forFile:[self FileTitle]];
}

- (void) pauseDownload
{
	if (![bar.possibleFilename length])
	{
		bar.possibleFilename =[self FileTitle];
	}
	if (!bar.downloadUrl)
	{
		bar.downloadUrl =[NSURL URLWithString:[self FileUrl]];
	}
	[bar pauseDownload];
}

- (void) continueDownload
{
	if (![bar.possibleFilename length])
	{
		bar.possibleFilename =[self FileTitle];
	}
	if (!bar.downloadUrl)
	{
		bar.downloadUrl =[NSURL URLWithString:[self FileUrl]];
	}
	[bar continueDownload];
}

- (void)downloadBar:(UIDownloadBar *)downloadBar didFinishWithData:(NSData *)fileData suggestedFilename:(NSString *)filename {

	if (filename != nil)
	{
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		[fileManager createFileAtPath:[NSString stringWithFormat:@"%@.mp4", [[paths objectAtIndex:0] stringByAppendingPathComponent:[self FileTitle]]] contents:fileData attributes:nil];
		
		NSString *imagePath = [NSString stringWithFormat:@"%@.png", [[paths objectAtIndex:0] stringByAppendingPathComponent:[self FileTitle]]];
		
		AVAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@.mp4", [[paths objectAtIndex:0] stringByAppendingPathComponent:[self FileTitle]]]] options:nil];
		
		AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
		
		Float64 durationSeconds = CMTimeGetSeconds(asset.duration);
		
		CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds / 2.0, 600);
		CMTime actualTime;
		
		CGImageRef preImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:NULL];
		
		if (preImage != NULL) {
			CGRect rect = CGRectMake(0.0, 0.0,120.0,70.0 );//CGImageGetWidth(preImage) * 0.5, CGImageGetHeight(preImage) * 0.5);
			
			UIImage *image = [UIImage imageWithCGImage:preImage];
			
			UIGraphicsBeginImageContext(rect.size);
			
			[image drawInRect:rect];
			
			NSData *data = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
			
			[fileManager createFileAtPath:imagePath contents:data attributes:nil];
			
			UIGraphicsEndImageContext();
		}
		
		CGImageRelease(preImage);
		[imageGenerator release];
		[asset release];
		operationCompleted =YES;
	}
	
	[self.delegate downloadDidFinish:self];
}

- (void)downloadBar:(UIDownloadBar *)downloadBar didFailWithError:(NSError *)error {
	[self.delegate downloadInfo:self didFailWithError:error];
}

- (void)downloadBarUpdated:(UIDownloadBar *)downloadBar 
{
	[self.delegate downloadUpdated:self];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)downloadBarPaused:(UIDownloadBar *)downloadBar forFile:(NSString *)filename
{
	[self.delegate downloadPaused:self forFile:filename];
}

- (void)downloadBarReStarted:(UIDownloadBar *)downloadBar forFile:(NSString *)filename
{
	[self.delegate downloadReStarted:self forFile:filename];
}

- (void)dealloc {
	[bar release];
	[key release];
	[value release];
	[super dealloc];
}
@end
