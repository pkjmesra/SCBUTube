

@class UIProgressView;
@protocol UIDownloadBarDelegate;

@interface UIDownloadBar : UIProgressView {
	NSURLRequest		*DownloadRequest;
	NSURLConnection		*DownloadConnection;
	NSMutableData		*receivedData;
	NSString			*localFilename;
	NSURL				*downloadUrl;
	id<UIDownloadBarDelegate> delegate;
	float				bytesReceived;
	long long			expectedBytes;
	
	BOOL				operationFinished,operationFailed,operationBreaked,inProgress;
	BOOL				operationIsOK;	
	BOOL				appendIfExist;
	FILE				*downFile;
	//NSString			*fileUrlPath;
	NSString			*possibleFilename;
	
	
	float percentComplete;
}

- (void)beginDownloadWithURL:(NSURL *)fileURL timeout:(NSInteger)timeout fileName:(NSString *)fileName;
- (UIDownloadBar *)initWithProgressBarFrame:(CGRect)frame delegate:(id<UIDownloadBarDelegate>)theDelegate;

@property (assign) BOOL operationIsOK;
@property (assign) BOOL operationBreaked;
@property (assign) BOOL inProgress;
@property (assign) BOOL operationFailed;
@property (assign) BOOL appendIfExist;
@property (assign) long long	expectedBytes;
@property (assign) float	bytesReceived;
//@property (nonatomic, copy) NSString *fileUrlPath;

@property (nonatomic, readwrite,retain) NSMutableData* receivedData;
@property (nonatomic, readonly, retain) NSURLRequest* DownloadRequest;
@property (nonatomic, readonly, retain) NSURLConnection* DownloadConnection;
@property (nonatomic, assign) id<UIDownloadBarDelegate> delegate;

@property (nonatomic, readonly) float percentComplete;
@property (nonatomic, retain) NSString *possibleFilename;
@property (nonatomic, retain) NSURL *downloadUrl;
- (void) forceStop;
- (void) pauseDownload;
- (void) continueDownload;
- (void) forceContinue;
-(void)saveDownloadInfo:(NSString *)inDirectory 
		  bytesReceived:(float)rcvdBytes 
		 createMainFile:(BOOL)createMainFile;
-(void)deleteSavedState;
@end


@protocol UIDownloadBarDelegate<NSObject>

@optional
- (void)downloadBar:(UIDownloadBar *)downloadBar didFinishWithData:(NSData *)fileData suggestedFilename:(NSString *)filename;
- (void)downloadBar:(UIDownloadBar *)downloadBar didFailWithError:(NSError *)error;
- (void)downloadBarUpdated:(UIDownloadBar *)downloadBar;
- (void)downloadBarPaused:(UIDownloadBar *)downloadBar forFile:(NSString *)filename;
- (void)downloadBarReStarted:(UIDownloadBar *)downloadBar forFile:(NSString *)filename;
@end
