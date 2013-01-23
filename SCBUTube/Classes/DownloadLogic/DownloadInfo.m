/**
 Copyright (c) 2011, Praveen K Jha, Research2Development Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list
 of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this
 list of conditions and the following disclaimer in the documentation and/or other
 materials provided with the distribution.
 Neither the name of the Research2Development Inc. nor the names of its contributors may be
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
@synthesize orgYTLink;
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
	[fileManager createFileAtPath:pausedFile contents:[@"" dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
//	NSString *attributes = [NSString stringWithFormat:@"Title=%@\nURL=%@\nExpectedBytes= %lld\nBytesReceived=%.2f\nOriginalYouTubeLink=%@\n",
//							[localFilename stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//							[[self FileUrl] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//							0, 
//							0, 
//                            [self.orgYTLink stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *attributes = [NSString stringWithFormat:@"Title=%@\nURL=%@\nExpectedBytes= %d\nBytesReceived=%d\nOriginalYouTubeLink=%@\n",
							[localFilename stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
							[[self FileUrl] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
							0, 
							0, 
                            [self.orgYTLink stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	/* Unused Variables 
    NSString *attributes1 = [NSString stringWithFormat:@"Title=%@",
							[localFilename stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *attributes2 = [NSString stringWithFormat:@"nURL=%@",
                             [[self FileUrl] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *attributes3 = [NSString stringWithFormat:@"nOriginalYouTubeLink=%@",
                             [self.orgYTLink stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    */
    
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
	if ([self.orgYTLink length] >0)  bar.orgYTLink = self.orgYTLink;
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
	bar.orgYTLink = self.orgYTLink;
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
