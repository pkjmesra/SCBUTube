/**
 Copyright (c) 2011, GlobalLogic Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list
 of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this
 list of conditions and the following disclaimer in the documentation and/or other
 materials provided with the distribution.
 Neither the name of the GlobalLogic Inc. nor the names of its contributors may be
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
/**
 PictureInPictureViewController.m
 PeerFun
 Abstract:  A view controller for managing and showing the outputs from front and rear camera
 Version: 1.0
 **/
#import "PictureInPictureViewController.h"
#import "videoFrameManager.h"

//! A view controller for managing and showing the outputs from front and rear camera
@implementation PictureInPictureViewController
@synthesize frontView;
@synthesize rearView;
@synthesize rearCamera;
@synthesize frontCamera;
@synthesize but;
@synthesize webView; // To be used when the facetime is implemented directly via browser
@synthesize sessionManager;
@synthesize frontCameraAvailable;
@synthesize isSimulator;
#pragma mark -
#pragma mark Camera delegate Methods

//! Processes the image received from rear camera on a background thread
-(void)backgroundRearCameraProcess:(UIImage*)image
{
    if (self.sessionManager == nil || self.sessionManager.currentConfPeerID == nil || self.isSimulator)
        [self.rearView setImage:image];
    
	//[self switchSessions:YES];
//    if (!self.frontCameraAvailable || self.isSimulator)
//    {
         NSData *packetData = UIImageJPEGRepresentation(image, 0.01f);
        videoFrameManager *frameMgr = [[videoFrameManager alloc] initWithImageFrameBuffer:packetData 
                                                                                  Manager:sessionManager];
        [operationQueue addOperation:frameMgr];
        [frameMgr release];
//    }
}

//! Processes the image received from front camera on a background thread
-(void)backgroundFrontCameraProcess:(UIImage*)image
{
	[self.frontView setImage:image];
	//[self switchSessions:NO];
    NSData *packetData = UIImageJPEGRepresentation(image, 0.01f);
    videoFrameManager *frameMgr = [[videoFrameManager alloc] initWithImageFrameBuffer:packetData 
                                                                              Manager:sessionManager];
	[operationQueue addOperation:frameMgr];
	[frameMgr release];
}


-(void) rearCameraReceiver:(UIImage*)image;
{
	[self backgroundRearCameraProcess:image];
    //NSLog(@"Rear Camera Image");
}

-(void) frontCameraReceiver:(UIImage*)image;
{
	[self backgroundFrontCameraProcess:image];
    //NSLog(@"Front Camera Image");
}

//! Switches from rear to front camera and vice-versa.
-(void) switchSessions//:(BOOL)isRear
{
	if([rearCamera.mySession isRunning])
	{
		//count=0;
		[rearCamera.mySession stopRunning];
		[frontCamera.mySession startRunning];
		NSString *toRear = [[NSString alloc] initWithString:@"Rear"];
		[but setTitle:toRear forState:UIControlStateNormal];
		[toRear release];
	}
	else
	{
		[frontCamera.mySession stopRunning];
		[rearCamera.mySession startRunning];
		NSString *toFront = [[NSString alloc] initWithString:@"Front"];
		[but setTitle:toFront forState:UIControlStateNormal];
		[toFront release];
	}
	//count++;
}

//! The button touch event handler to switch from rear to front camera and vice-versa.
-(IBAction)Switch
{
#if !TARGET_IPHONE_SIMULATOR
	[self switchSessions];
#endif
}

#pragma mark -
#pragma mark view delegate Methods
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
#if !TARGET_IPHONE_SIMULATOR
	rearCamera = [[Camera alloc]init];
	[rearCamera setDelegateController:self];
	rearCamera.isRear = YES;
	[rearCamera setupCaptureSession];
	
	frontCamera = [[Camera alloc]init];
	[frontCamera setDelegateController:self];
	frontCamera.isRear = NO;
	[frontCamera setupCaptureSession];
    //[frontCamera.mySession startRunning];
    // Custom initialization
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:2];
    
    self.frontCameraAvailable =([Camera frontFacingCameraIfAvailable] != nil);
#endif
}

- (void) viewDidAppear:(BOOL)animated
{
#if !TARGET_IPHONE_SIMULATOR
    [frontCamera.mySession stopRunning];
    [rearCamera.mySession startRunning];
    [but setTitle:@"Front" forState:UIControlStateNormal];
    BOOL enable =([Camera frontFacingCameraIfAvailable] !=nil);
    [but setEnabled:enable];
    [self rearView].hidden = NO;
#endif
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[but release];
	[frontView release];
	[rearView release];
#if !TARGET_IPHONE_SIMULATOR
	[rearCamera release];
	[frontCamera release];
#endif
    [sessionManager release];
    [super dealloc];
}

@end
