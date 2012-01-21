

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