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

#import "DownloadInfo.h"
#import "DownloadManager.h"
#import "SlideToCancelViewController.h"
#import "DownloadQViewController.h"

@interface SCBUTubeViewController : UIViewController <DownloadManagerDelegate,SlideToCancelDelegate,DownloadInfoDelegate,UIWebViewDelegate> 
{
    IBOutlet UIBarButtonItem *downloadButton;
	IBOutlet UIBarButtonItem *addIntoQueueButton;
	IBOutlet UIBarButtonItem *goBackButton;
	IBOutlet UIBarButtonItem *goFwdButton;
	IBOutlet UIBarButtonItem *qProgressButton;
	IBOutlet UIBarButtonItem *pauseAllButton;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UIWebView *webView;
	BOOL isPaused;
	DownloadManager *manager;
	SlideToCancelViewController *slideToCancel;
	DownloadQViewController *queuedViewController;
}
@property (nonatomic,retain) DownloadQViewController *queuedViewController;

- (IBAction)download;
- (IBAction)QueueForDownload;
- (IBAction)onGoPreviousPage;
- (IBAction)onGoNextPage;
- (IBAction)presentDownloads;
- (IBAction)presentQueuedDownloads;
- (IBAction)pauseDownloads;

-(void)pauseAll;
@end