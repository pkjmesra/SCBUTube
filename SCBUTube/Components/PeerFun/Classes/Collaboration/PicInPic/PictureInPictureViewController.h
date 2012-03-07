/**
 Copyright (c) 2011, Research2Development Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list
 of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this
 list of conditions and the following disclaimer in the documentation and/or other
 materials provided with the distribution.
 Neither the name of the Research2Development Inc. nor the names of its contributors may be
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
 PictureInPictureViewController.h
 PeerFun
 Abstract:  A view controller for managing and showing the outputs from front and rear camera
 Version: 1.0
 **/
#import <UIKit/UIKit.h>
#import "Camera.h"
#import "SessionManager.h"

@class ImagePickerView;
//! A view controller for managing and showing the outputs from front and rear camera
@interface PictureInPictureViewController : UIViewController<CameraProtocal,UINavigationControllerDelegate> {
	UIImageView *rearView;
	UIImageView *frontView;
	Camera * rearCamera;
	Camera *frontCamera;
	UIButton *but;
    UIWebView *webView;
    NSOperationQueue *operationQueue;
    SessionManager *sessionManager;
    BOOL frontCameraAvailable;
    BOOL isSimulator;
}
//! Gets or sets the button using which you can switch from and to front/rear camera
@property (nonatomic, retain) IBOutlet UIButton *but;
//! Gets or sets the rear camera image view
@property (nonatomic, retain) IBOutlet UIImageView *rearView;
//! Gets or sets the front camera image view
@property (nonatomic, retain) IBOutlet UIImageView *frontView;
//! Gets or sets the session manager object for sending the image data to 2nd party
@property (nonatomic, retain) SessionManager *sessionManager;
//! Gets or sets a value indicating if the front camera is supported in the device
@property (nonatomic) BOOL frontCameraAvailable;
//! Gets or sets a value indicating if the app is being run on simulator
@property (nonatomic) BOOL isSimulator;
//! Gets or sets the rear end camera object
@property (nonatomic, retain) Camera * rearCamera;
//! Gets or sets the front end camera object
@property (nonatomic, retain) Camera *frontCamera;
/**
 Gets or sets the web view browser object which can be used to display the
 streaming images in M-JPEG format. This is not implemented in this application
 but needs only a few more lines of code to do so.
 **/
@property(nonatomic,retain) IBOutlet UIWebView *webView;
//! Processes the image received from rear camera on a background thread
-(void)backgroundRearCameraProcess:(UIImage*)image;
//! Processes the image received from front camera on a background thread
-(void)backgroundFrontCameraProcess:(UIImage*)image;
//! The button touch event handler to switch from rear to front camera and vice-versa.
-(IBAction)Switch;

@end

