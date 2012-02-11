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
 CameraProtocal.h
 PeerFun
 Abstract:  A Camera Protocal contract to receive camera images from different sources
 Version: 1.0
 **/
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreGraphics/CoreGraphics.h>

//! A Camera Protocal contract to receive camera images from different sources
@protocol CameraProtocal

//! Receives the image from rear end camera
-(void)rearCameraReceiver:(UIImage*)image;
//! Receives the image from front end camera
-(void)frontCameraReceiver:(UIImage*)image;

@end

//! A camera object to handle input and output images
@interface Camera : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate> 
{
	id<CameraProtocal> delegateController;
	AVCaptureSession *mySession;
	BOOL isRear;
}

//! Returns an image object from the buffer received from camera
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
//! Sets up the capture session for capture from one of the available cameras
- (void)setupCaptureSession;
//! Checks to see if the front facing camera is available, if so return the capture device for the same.
+ (AVCaptureDevice *)frontFacingCameraIfAvailable;

//! Gets or sets the delegate for camera controller
@property(nonatomic, assign) id delegateController;
//! Gets or sets the capture session object
@property (nonatomic, retain) AVCaptureSession *mySession;
//! Gets a value indicating if the camera session is being initialized for rear camera.
@property BOOL isRear;

@end
