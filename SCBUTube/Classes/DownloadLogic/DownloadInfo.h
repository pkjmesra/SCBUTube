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
//
//  DownloadInfo.h
//  SCBUTube
//
//  Created by Praveen Jha on 12/01/12.
//  Copyright (c) 2012 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIDownloadBar.h"

@protocol DownloadInfoDelegate;
@interface DownloadInfo : NSObject<UIDownloadBarDelegate>
{
	float percentComplete;
	id<DownloadInfoDelegate> delegate;
	UIDownloadBar *bar;

	NSString *key;
	NSString * value;
	NSString *orgYTLink;
	BOOL operationCompleted;
}
@property (nonatomic, readonly) float percentComplete;
@property (nonatomic, retain) UIDownloadBar *bar;
@property (nonatomic, assign) id<DownloadInfoDelegate> delegate;
@property (nonatomic, assign) BOOL operationCompleted;
@property (nonatomic,retain) NSString *orgYTLink;
- (void)setObject:(id)anObject forKey:(id)aKey;
- (NSUInteger)count;

-(NSString *) FileTitle;
-(NSString *) FileUrl;
-(BOOL)setUp:(BOOL)startImmediate;
-(void)beginDownload;
- (void) pauseDownload;
- (void) continueDownload;
-(void)saveDownloadInfo;
-(void)setUpWithPausedDownload:(long long)expectedBytes ReceivedBytes:(float)bytesReceived;
-(NSData *)loadQueuedOrPausedItemContents;
-(void)dropDownload;
@end

@protocol DownloadInfoDelegate<NSObject>

@optional
- (void)downloadDidFinish:(DownloadInfo *)info;
- (void)downloadInfo:(DownloadInfo *)info didFailWithError:(NSError *)error;
- (void)downloadUpdated:(DownloadInfo *)info;
- (void)downloadPaused:(DownloadInfo *)info forFile:(NSString *)filename;
- (void)downloadDropped:(DownloadInfo *)info forFile:(NSString *)filename;
- (void)downloadReStarted:(DownloadInfo *)info forFile:(NSString *)filename;
@end
