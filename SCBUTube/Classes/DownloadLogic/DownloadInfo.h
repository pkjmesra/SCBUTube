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
	BOOL operationCompleted;
}
@property (nonatomic, readonly) float percentComplete;
@property (nonatomic, retain) UIDownloadBar *bar;
@property (nonatomic, assign) id<DownloadInfoDelegate> delegate;
@property (nonatomic, assign) BOOL operationCompleted;

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
