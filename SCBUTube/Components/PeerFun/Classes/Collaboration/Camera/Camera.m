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
 CameraProtocal.m
 PeerFun
 Abstract:  A Camera Protocal contract to receive camera images from different sources
 Version: 1.0
 **/
#import "Camera.h"
#import "AssetsLibrary/ALAssetsLibrary.h"

//! A Camera Protocal contract to receive camera images from different sources
@implementation Camera

@synthesize delegateController;
@synthesize mySession, isRear;

#pragma mark -
#pragma mark CaptureMehtodSequence

//! Checks to see if the rear facing camera is available, if so return the capture device for the same.
- (AVCaptureDevice *)backFacingCameraIfAvailable
{
    //  look at all the video devices and get the first one that's on the front
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionBack)
        {
            captureDevice = device;
            break;
        }
    }
	return captureDevice;
}

//! Checks to see if the front facing camera is available, if so return the capture device for the same.
+ (AVCaptureDevice *)frontFacingCameraIfAvailable
{
    //  look at all the video devices and get the first one that's on the front
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionFront)
        {
            captureDevice = device;
            break;
        }
    }
	return captureDevice;
}

//! Sets up the capture session for capture from one of the available cameras
- (void)setupCaptureSession
{
    NSError *error = nil;

    // Create the session
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
	
    // Configure the session to produce lower resolution video frames, if your 
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
    //session.sessionPreset = AVCaptureSessionPresetMedium;
	session.sessionPreset = AVCaptureSessionPresetMedium;
	
    // Find a suitable AVCaptureDevice
	AVCaptureDevice *camera;
	if(!isRear)
	{
		camera= [Camera frontFacingCameraIfAvailable];
	}
	else
	{
		camera= [self backFacingCameraIfAvailable];
	}
	
	if (camera != nil) {//if Not available
		
		AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:camera error:&error];
		//AVCaptureDeviceInput *inputAudio = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
		
		
		if (!input) {
			// Handling the error appropriately
			[session release];
			return;
		}
		if([session canAddInput:input])
		{
			[session addInput:input];
			
			// Create a VideoDataOutput and add it to the session
			AVCaptureVideoDataOutput *output = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
			[session addOutput:output];
			
			// Configure your output.
			NSString* qName = [[NSString alloc ]  initWithFormat:@"%d-Queue",isRear];
			dispatch_queue_t queue = dispatch_queue_create(qName, NULL);
			[output setSampleBufferDelegate:self queue:queue];
			[qName release];
			dispatch_release(queue);
			
			// Specify the pixel format
			output.videoSettings = 
			[NSDictionary dictionaryWithObject:
			 [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] 
										forKey:(id)kCVPixelBufferPixelFormatTypeKey];
			
			// minFrameDuration.
			//output.minFrameDuration = CMTimeMake(1, 15)// If you wish to cap the frame rate to a known value, such as 15 fps, set
			output.minFrameDuration = CMTimeMake(1, 0);//kCMTimeZero or kCMTimeInvalid indicates an unlimited maximum frame rate. The default value is kCMTimeInvalid 
			output.alwaysDiscardsLateVideoFrames = YES;
		}		
	}	
	
    // Start the session running to start the flow of data
    //[session startRunning];
	
    // Assign session to an ivar.
    [self setMySession:session];
}

//! Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput	didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
	   fromConnection:(AVCaptureConnection *)connection
{
	// Create a UIImage from the sample buffer data
	UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
	if(isRear)
	{
		[self.delegateController performSelectorOnMainThread:@selector(rearCameraReceiver:) withObject:image waitUntilDone:NO];
	}
	else
	{
		[self.delegateController performSelectorOnMainThread:@selector(frontCameraReceiver:) withObject:image waitUntilDone:NO];
		//< Add your code here that uses the image >
	}	
}

//! Returns an image object from the buffer received from camera
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer 
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0); 
	
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer); 
	
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer); 
	
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
	
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, 
												 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst); 
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context); 
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
	
    // Free up the context and color space
    CGContextRelease(context); 
    CGColorSpaceRelease(colorSpace);
	
    // Create an image object from the Quartz image
    //UIImage *image = [UIImage imageWithCGImage:quartzImage];
	UIImage *image= [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:UIImageOrientationRight];
	
    // Release the Quartz image
    CGImageRelease(quartzImage);
	
    return (image);
}

@end
