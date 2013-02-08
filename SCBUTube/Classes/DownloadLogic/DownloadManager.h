/**
 Copyright (c) 2011, Praveen K Jha, Praveen K Jha.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list
 of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this
 list of conditions and the following disclaimer in the documentation and/or other
 materials provided with the distribution.
 Neither the name of the Praveen K Jha. nor the names of its contributors may be
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
//  DownloadManager.h
//  SCBUTube
//
//  Created by Praveen Jha on 12/01/12.
//  Copyright (c) 2012 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadInfo.h"

@protocol DownloadManagerDelegate;

@interface DownloadManager : NSObject<DownloadInfoDelegate>
{
	NSMutableArray *queue;
	id<DownloadManagerDelegate> delegate;
	BOOL isIdle;
}
@property (nonatomic, retain) NSMutableArray *queue;
@property (nonatomic, assign) id<DownloadManagerDelegate> delegate;

-(void)addNewDownloadItem:(DownloadInfo *)item;
-(void) start;
-(void) pause;
-(void) forceStop;
-(void) forceContinue;
-(void)continueDownload;
-(void)loadQueuedOrPausedItems;
@end

@protocol DownloadManagerDelegate<NSObject>

@optional
- (void)downloadManagerDidFinish:(DownloadInfo *)info;
- (void)downloadManagerInfo:(DownloadInfo *)info didFailWithError:(NSError *)error;
- (void)downloadManagerUpdated:(DownloadInfo *)info;
- (void)downloadManagerDropped:(DownloadInfo *)info forFile:(NSString *)filename;
- (void)downloadManagerPaused:(DownloadInfo *)info forFile:(NSString *)filename;
- (void)downloadManagerReStarted:(DownloadInfo *)info forFile:(NSString *)filename;
@end
