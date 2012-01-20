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
