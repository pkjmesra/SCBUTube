
#import "DownloadQViewController.h"
#import "DownloadsViewController.h"
#import "SCBUTubeViewController.h"

@implementation SCBUTubeViewController

@synthesize queuedViewController;
int looper;
#pragma mark -
#pragma mark View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [webView setBackgroundColor:[UIColor clearColor]];
	manager = [[DownloadManager alloc] init];
	manager.delegate = self;
	if (manager.queue.count >0)
	{
		isPaused = YES;
		[pauseAllButton setImage:[UIImage imageNamed:@"ReStart.png"]];
	}
}

-(NSString *)loadLastViewState
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *attribFile =[NSString stringWithFormat:@"%@/lastView.state", [paths objectAtIndex:0]];
	NSData *fileData;
	if([fileManager fileExistsAtPath:attribFile isDirectory:NO])
	{
		fileData = [NSData dataWithContentsOfFile:attribFile];
	}
	else
	{
		fileData = [[NSString stringWithString:@"http://m.youtube.com"] dataUsingEncoding:NSUTF8StringEncoding];
	}
	return [[[NSString alloc ] initWithData:fileData encoding:NSUTF8StringEncoding] autorelease];
}

-(void)saveLastViewState
{
	NSString *url=[webView stringByEvaluatingJavaScriptFromString:@"function getUrl(){return window.location.href;} getUrl();"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *attribFile =[NSString stringWithFormat:@"%@/lastView.state", [paths objectAtIndex:0]];
	if([fileManager fileExistsAtPath:attribFile isDirectory:NO])
	{
		[fileManager removeItemAtPath:attribFile error:nil];
	}
	[fileManager createFileAtPath:attribFile 
							 contents:[url dataUsingEncoding:NSUTF8StringEncoding] 
						   attributes:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (!webView.request.URL) {
		[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self loadLastViewState]]]];
	}
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// TODO: Remove all current downloads from download manager
	[downloadButton setEnabled:YES];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self loadLastViewState]]]];
}

-(DownloadInfo*)trySetUpDownload
{
	UIUserInterfaceIdiom userInterfaceIdiom = [UIDevice currentDevice].userInterfaceIdiom;
    
    NSString *getURL = @"";
    
    if (userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        getURL = [webView stringByEvaluatingJavaScriptFromString:@"function getURL() {var player = document.getElementById('player'); var video = player.getElementsByTagName('video')[0]; return video.getAttribute('src');} getURL();"];
    } else {
        getURL = [webView stringByEvaluatingJavaScriptFromString:@"function getURL() {var bh = document.getElementsByClassName('bh'); if (bh.length) {return bh[0].getAttribute('src');} else {var zq = document.getElementsByClassName('zq')[0]; return zq.getAttribute('src');}} getURL();"];
    }
    NSLog(@"geturl is %@",getURL);
	//getURL =@"http://s.ytimg.com/yt/swfbin/watch_as3-vfl7SkMGe.swf";
    NSString *getTitle = [webView stringByEvaluatingJavaScriptFromString:@"function getTitle() {var qo = document.getElementsByClassName('qo')[0]; if (qo) return qo.innerHTML; else {var jm = document.getElementsByClassName('jm'); if (jm.length) {return jm[0].innerHTML;} else {var lp = document.getElementsByClassName('lp')[0]; if (lp && lp.childNodes.length > 0) {return lp.childNodes[0].innerHTML;}}}} getTitle();"];
    
	NSString *getTitleFromChannel = [webView stringByEvaluatingJavaScriptFromString:@"function getElementsByAttribute(oElm, strTagName,strAttributeName, strAttributeValue){     var arrElements = (strTagName == '*' && oElm.all)? oElm.all : oElm.getElementsByTagName(strTagName);     var arrReturnElements = new Array();     var oAttributeValue = (typeof strAttributeValue != 'undefined')? new RegExp('(^|\\s)' + strAttributeValue + '(\\s|$)', 'i') : null;     var oCurrent;     var oAttribute;     for(var i=0; i<arrElements.length; i++){     oCurrent = arrElements[i];     oAttribute = oCurrent.getAttribute && oCurrent.getAttribute(strAttributeName);     if(typeof oAttribute == 'string' && oAttribute.length > 0){     if(typeof strAttributeValue == 'undefined' || (oAttributeValue && oAttributeValue.test(oAttribute))){     arrReturnElements.push(oCurrent);     }     }     }     return arrReturnElements;     }; getElementsByAttribute(document,'div','page_element_id','video_details')[0].childNodes[0].childNodes[0].innerHTML;"];
    
    NSLog(@"%@, %@", getTitle, getTitleFromChannel);
    
	[webView setUserInteractionEnabled:YES];
	
	NSArray *components = [getTitle componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
	getTitle = [components componentsJoinedByString:@" "];
	DownloadInfo *info=[[DownloadInfo alloc] init];
	if ([getURL length] > 0) 
	{
		if ([getTitle length] > 0) 
		{
			[info setObject:getURL forKey:getTitle];
		} 
		else 
		{
			NSArray *components = [getTitleFromChannel componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
			getTitleFromChannel = [components componentsJoinedByString:@" "];
			
			if ([getTitleFromChannel length] > 0) 
			{
					[info setObject:getURL forKey:getTitleFromChannel];
			} 
			else 
			{
                //NSLog(@"%@", [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('html')[0].innerHTML;"]);
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SCBUTube" message:@"Couldn't get video title." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alertView show];
                [alertView release];
                
				[downloadButton setEnabled:YES];
			}
		}
	} 
	else 
	{
        //NSLog(@"%@", [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('html')[0].innerHTML;"]);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SCBUTube" message:@"Couldn't get MP4 URL." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
        
		[downloadButton setEnabled:YES];
	}
	return info;
}

#pragma mark -
#pragma mark IBActions

- (IBAction)download 
{
	DownloadInfo *dinfo=[self trySetUpDownload];
	if ([[dinfo FileTitle] length] >0 && [[dinfo FileUrl] length] >0)
	{
		[downloadButton setEnabled:NO];
		dinfo.delegate = self;
		[dinfo setUp:YES];
		[toolbar addSubview:dinfo.bar];
	}
}

// SlideToCancelDelegate method is called when the slider is slid all the way
// to the right
- (void) cancelled {
	// Disable the slider and re-enable the button
	slideToCancel.enabled = NO;
	
	// Slowly move down the slider off the bottom of the screen
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	CGPoint sliderCenter = slideToCancel.view.center;
	sliderCenter.y += slideToCancel.view.bounds.size.height;
	slideToCancel.view.center = sliderCenter;
	[UIView commitAnimations];
}

- (void) showQueueConfirmation:(NSString *)localizedText
{
	if (slideToCancel)
	{
//		slideToCancel.delegate = nil;
//		[slideToCancel release];
		slideToCancel = nil;	
	}
	
	if (!slideToCancel) {
		// Create the slider
		slideToCancel = [[SlideToCancelViewController alloc] init];
		slideToCancel.localizedStatusText =localizedText;
		slideToCancel.delegate = self;
		
		// Position the slider off the bottom of the view, so we can slide it up
		CGRect sliderFrame = slideToCancel.view.frame;
		sliderFrame.origin.y = self.view.frame.size.height;
		slideToCancel.view.frame = sliderFrame;
		
		// Add slider to the view
		[self.view addSubview:slideToCancel.view];
	}
//	slideToCancel.localizedStatusText =localizedText;
	// Start the slider animation
	slideToCancel.enabled = YES;
	
	// Slowly move up the slider from the bottom of the screen
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	CGPoint sliderCenter = slideToCancel.view.center;
	sliderCenter.y -= slideToCancel.view.bounds.size.height;
	slideToCancel.view.center = sliderCenter;
	[UIView commitAnimations];
	
	[self performSelector:@selector(cancelled) withObject:nil afterDelay:2];
}

- (IBAction)QueueForDownload
{
	DownloadInfo *dinfo=[self trySetUpDownload];
	if ([[dinfo FileTitle] length] >0 && [[dinfo FileUrl] length] >0)
	{
		[dinfo setUp:NO];
		[manager addNewDownloadItem:dinfo];
		[manager start];
		[self showQueueConfirmation:NSLocalizedString(@"Queue Updated!", @"SlideToCancel label for Queue Update")];
	}
	else
		[dinfo release];
}

- (IBAction)presentDownloads {
	DownloadsViewController *viewController = [[DownloadsViewController alloc] initWithNibName:@"Downloads" bundle:nil];
	
	[self presentModalViewController:viewController animated:YES];
	
	[viewController release];
}

- (IBAction)presentQueuedDownloads {

	if (!self.queuedViewController)
	{
		DownloadQViewController *viewController = [[DownloadQViewController alloc] initWithNibName:@"DownloadQueue" bundle:nil];
		self.queuedViewController = viewController;
		[viewController release];
	}
	if (manager.queue)
	{
		[self.queuedViewController setContents:manager.queue];
	}
	[self presentModalViewController:self.queuedViewController animated:YES];
}

- (IBAction)onGoPreviousPage
{
	[webView goBack];
}

-(void)pauseAll
{
	[manager pause];
	[pauseAllButton setImage:[UIImage imageNamed:@"ReStart.png"]];
	isPaused =YES;
}

- (IBAction)pauseDownloads
{
	if (manager.queue.count <=0)
	{
		[self showQueueConfirmation:NSLocalizedString(@"Nothing Queued!", @"SlideToCancel label for Nothing Queued")];
		return;
	}
	
	if (!isPaused)
	{
		[self pauseAll];
		isPaused =YES;
		[self showQueueConfirmation:NSLocalizedString(@"Downloads Paused!", @"SlideToCancel label for Downloads Paused")];
	}
	else
	{
		isPaused =NO;
		[manager continueDownload];
		[self showQueueConfirmation:NSLocalizedString(@"Downloads Restarted!", @"SlideToCancel label for Downloads Restarted")];
	}
	
	if (isPaused)
	{
		[pauseAllButton setImage:[UIImage imageNamed:@"ReStart.png"]];
	}
	else
	{
		[pauseAllButton setImage:[UIImage imageNamed:@"pause.png"]];
	}
}

-(void)updateToolbar
{
	int pausedCount =0;
	[pauseAllButton setImage:[UIImage imageNamed:@"pause.png"]];
	isPaused=NO;
	for (DownloadInfo *dInfo in manager.queue)
	{
		if (dInfo.bar.operationBreaked)
			pausedCount++;
	}
	if (pausedCount ==manager.queue.count)
	{
		[pauseAllButton setImage:[UIImage imageNamed:@"ReStart.png"]];
		isPaused =YES;
	}
}

-(void)reloadQueuedController
{
	if(self.queuedViewController && 
	   self.queuedViewController.isViewLoaded && 
	   self.queuedViewController.view.window)
	{
		self.queuedViewController.isReloading=!self.queuedViewController.isReloading;
		[self.queuedViewController reloadAllData];
	}
}

#pragma mark -
#pragma mark Delegates

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[self saveLastViewState];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)downloadDidFinish:(DownloadInfo *)info
{	
	[downloadButton setEnabled:YES];
	[info.bar removeFromSuperview];
}

- (void)downloadInfo:(DownloadInfo *)info didFailWithError:(NSError *)error 
{
	[downloadButton setEnabled:YES];
	[info.bar removeFromSuperview];
}

- (void)downloadUpdated:(DownloadInfo *)info {}

- (void)downloadManagerDidFinish:(DownloadInfo *)info
{
	self.queuedViewController.isReloading =NO;
	if(self.queuedViewController && 
	   self.queuedViewController.isViewLoaded && 
	   self.queuedViewController.view.window)
	{
		[self.queuedViewController setContents:manager.queue];
		[self.queuedViewController reloadAllData];
	}
}

- (void)downloadManagerInfo:(DownloadInfo *)info didFailWithError:(NSError *)error 
{
	self.queuedViewController.isReloading =NO;
	[self performSelector:@selector(reloadQueuedController) withObject:nil afterDelay:0];
	[self updateToolbar];
}

- (void)downloadManagerUpdated:(DownloadInfo *)info
{
//	if (info && info.bar && info.bar.tag>=0)
//	{
////		NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:info.bar.tag];
//		[self.queuedViewController reloadRowsAtIndexPath:info.bar.tag];
//	}
	if (!self.queuedViewController.isReloading || looper>=50)
	{
		[self performSelector:@selector(reloadQueuedController) withObject:nil afterDelay:3];
	}
	else
		looper++;
}
- (void)downloadManagerPaused:(DownloadInfo *)info forFile:(NSString *)filename
{
	self.queuedViewController.isReloading =NO;
	[self updateToolbar];
}
- (void)downloadManagerReStarted:(DownloadInfo *)info forFile:(NSString *)filename
{
	self.queuedViewController.isReloading =NO;
	[self updateToolbar];
}

- (void)downloadManagerDropped:(DownloadInfo *)info forFile:(NSString *)filename
{
	self.queuedViewController.isReloading =NO;
	[self updateToolbar];
	if(self.queuedViewController && 
	   self.queuedViewController.isViewLoaded && 
	   self.queuedViewController.view.window)
	{
		[self.queuedViewController setContents:manager.queue];
		[self.queuedViewController reloadAllData];
	}
	[self updateToolbar];
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[queuedViewController release];
	[slideToCancel release];
    [super dealloc];
}

@end