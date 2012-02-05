//
//  Objective_ZipViewController.m
//  Objective-Zip
//
//  Created by Gianluca Bertani on 25/12/09.
//  Copyright Flying Dolphin Studio 2009. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without 
//  modification, are permitted provided that the following conditions 
//  are met:
//
//  * Redistributions of source code must retain the above copyright notice, 
//    this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, 
//    this list of conditions and the following disclaimer in the documentation 
//    and/or other materials provided with the distribution.
//  * Neither the name of Gianluca Bertani nor the names of its contributors 
//    may be used to endorse or promote products derived from this software 
//    without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
//  POSSIBILITY OF SUCH DAMAGE.
//

#import "Objective_Zipper.h"
#import "ZipFile.h"
#import "ZipException.h"
#import "FileInZipInfo.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"
#import "DDLog.h"
#import "DDFileLogger.h"

@implementation Objective_Zipper

- (void) dealloc {
	if (_testThread)
		[_testThread release];
    [super dealloc];
}

- (NSData *) zip:(NSString *)path {
//	if (_testThread)
//		[_testThread release];
//	
//	_testThread= [[NSThread alloc] initWithTarget:self selector:@selector(createZip:) object:path];
//	[_testThread start];
	return [self createZip:path];
}

- (void) unZip:(NSString *)path {
	if (_testThread)
		[_testThread release];
	
	_testThread= [[NSThread alloc] initWithTarget:self selector:@selector(test) object:nil];
	[_testThread start];
}

-(NSData *)createZip:(NSString *)path
{
		NSAutoreleasePool *pool= [[NSAutoreleasePool alloc] init];
		NSString *filePath= [path stringByAppendingPathComponent:@"ZippedFile.zip"];
		@try 
		{
			NSLog(@"docFullPath :%@",path);
			NSString* file;
			NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
			[self performSelectorOnMainThread:@selector(log:) withObject:@"Opening zip file for writing..." waitUntilDone:YES];
			ZipFile *zipFile= [[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeCreate];
			
			while (file = [enumerator nextObject])
			{
				if ([file hasSuffix:@".attrib"])
				{
					// open your file …
					DDLogFileInfo *logFileInfo = [[DDLogFileInfo alloc ]initWithFilePath:[NSString stringWithFormat:@"%@/%@",path,file]];
					
					[self performSelectorOnMainThread:@selector(log:) withObject:@"Adding files..." waitUntilDone:YES];
					
					ZipWriteStream *stream1= [zipFile writeFileInZipWithName:logFileInfo.fileName fileDate:[logFileInfo creationDate] compressionLevel:ZipCompressionLevelBest];
					
					[self performSelectorOnMainThread:@selector(log:) withObject:@"Writing to first file's stream..." waitUntilDone:YES];
					
					[stream1 writeData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",path,file]]];
					
					[self performSelectorOnMainThread:@selector(log:) withObject:@"Closing first file's stream..." waitUntilDone:YES];
					
					[stream1 finishedWriting];
				}
			
			}
			[self performSelectorOnMainThread:@selector(log:) withObject:@"Closing zip file..." waitUntilDone:YES];
			
			[zipFile close];
			[zipFile release];
			
			return [NSData dataWithContentsOfFile:filePath];
		}
		@catch (ZipException *ze) {
			[self performSelectorOnMainThread:@selector(log:) withObject:@"Caught a ZipException (see logs), terminating..." waitUntilDone:YES];
			
			NSLog(@"ZipException caught: %d - %@", ze.error, [ze reason]);
			return nil;
		} 
		@catch (id e) 
		{
			[self performSelectorOnMainThread:@selector(log:) withObject:@"Caught a generic exception (see logs), terminating..." waitUntilDone:YES];
			
			NSLog(@"Exception caught: %@ - %@", [[e class] description], [e description]);
			return nil;
		}
		@finally 
		{
			[[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
		}
		[pool drain];
}

- (void) test {
    NSAutoreleasePool *pool= [[NSAutoreleasePool alloc] init];

	@try {
		NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
		NSString *filePath= [documentsDir stringByAppendingPathComponent:@"test.zip"];

		[self performSelectorOnMainThread:@selector(log:) withObject:@"Opening zip file for writing..." waitUntilDone:YES];
		
		ZipFile *zipFile= [[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeCreate];

		[self performSelectorOnMainThread:@selector(log:) withObject:@"Adding first file..." waitUntilDone:YES];
		
		ZipWriteStream *stream1= [zipFile writeFileInZipWithName:@"abc.txt" fileDate:[NSDate dateWithTimeIntervalSinceNow:-86400.0] compressionLevel:ZipCompressionLevelBest];

		[self performSelectorOnMainThread:@selector(log:) withObject:@"Writing to first file's stream..." waitUntilDone:YES];

		NSString *text= @"abc";
		[stream1 writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];

		[self performSelectorOnMainThread:@selector(log:) withObject:@"Closing first file's stream..." waitUntilDone:YES];
		
		[stream1 finishedWriting];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Adding second file..." waitUntilDone:YES];
		
		ZipWriteStream *stream2= [zipFile writeFileInZipWithName:@"x/y/z/xyz.txt" compressionLevel:ZipCompressionLevelNone];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Writing to second file's stream..." waitUntilDone:YES];
		
		NSString *text2= @"XYZ";
		[stream2 writeData:[text2 dataUsingEncoding:NSUTF8StringEncoding]];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Closing second file's stream..." waitUntilDone:YES];
		
		[stream2 finishedWriting];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Closing zip file..." waitUntilDone:YES];
		
		[zipFile close];
		[zipFile release];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Opening zip file for reading..." waitUntilDone:YES];
		
		ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeUnzip];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Reading file infos..." waitUntilDone:YES];
		
		NSArray *infos= [unzipFile listFileInZipInfos];
		for (FileInZipInfo *info in infos) {
			NSString *fileInfo= [NSString stringWithFormat:@"- %@ %@ %d (%d)", info.name, info.date, info.size, info.level];
			[self performSelectorOnMainThread:@selector(log:) withObject:fileInfo waitUntilDone:YES];
		}
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Opening first file..." waitUntilDone:YES];
		
		[unzipFile goToFirstFileInZip];
		ZipReadStream *read1= [unzipFile readCurrentFileInZip];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Reading from first file's stream..." waitUntilDone:YES];
		
		NSMutableData *data1= [[[NSMutableData alloc] initWithLength:256] autorelease];
		int bytesRead1= [read1 readDataWithBuffer:data1];
		
		BOOL ok= NO;
		if (bytesRead1 == 3) {
			NSString *fileText1= [[[NSString alloc] initWithBytes:[data1 bytes] length:bytesRead1 encoding:NSUTF8StringEncoding] autorelease];
			if ([fileText1 isEqualToString:@"abc"])
				ok= YES;
		}
		
		if (ok)
			[self performSelectorOnMainThread:@selector(log:) withObject:@"Content of first file is OK" waitUntilDone:YES];
		else
			[self performSelectorOnMainThread:@selector(log:) withObject:@"Content of first file is WRONG" waitUntilDone:YES];
			
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Closing first file's stream..." waitUntilDone:YES];
		
		[read1 finishedReading];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Opening second file..." waitUntilDone:YES];

		[unzipFile goToNextFileInZip];
		ZipReadStream *read2= [unzipFile readCurrentFileInZip];

		[self performSelectorOnMainThread:@selector(log:) withObject:@"Reading from second file's stream..." waitUntilDone:YES];
		
		NSMutableData *data2= [[[NSMutableData alloc] initWithLength:256] autorelease];
		int bytesRead2= [read2 readDataWithBuffer:data2];
		
		ok= NO;
		if (bytesRead2 == 3) {
			NSString *fileText2= [[[NSString alloc] initWithBytes:[data2 bytes] length:bytesRead2 encoding:NSUTF8StringEncoding] autorelease];
			if ([fileText2 isEqualToString:@"XYZ"])
				ok= YES;
		}
		
		if (ok)
			[self performSelectorOnMainThread:@selector(log:) withObject:@"Content of second file is OK" waitUntilDone:YES];
		else
			[self performSelectorOnMainThread:@selector(log:) withObject:@"Content of second file is WRONG" waitUntilDone:YES];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Closing second file's stream..." waitUntilDone:YES];
		
		[read2 finishedReading];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Closing zip file..." waitUntilDone:YES];
		
		[unzipFile close];
		[unzipFile release];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test terminated succesfully" waitUntilDone:YES];
		
	} @catch (ZipException *ze) {
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Caught a ZipException (see logs), terminating..." waitUntilDone:YES];
		
		NSLog(@"ZipException caught: %d - %@", ze.error, [ze reason]);

	} @catch (id e) {
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Caught a generic exception (see logs), terminating..." waitUntilDone:YES];

		NSLog(@"Exception caught: %@ - %@", [[e class] description], [e description]);
	}
	
	[pool drain];
}

- (void) log:(NSString *)text {
	NSLog(@"%@", text);
}

@end
