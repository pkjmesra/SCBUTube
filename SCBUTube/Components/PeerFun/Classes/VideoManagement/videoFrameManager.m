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
 videoFrameManager.m
 PeerFun
 Abstract:  Manages the video frames and sends the frames in queue to the
            second party via session manager.
 Version: 1.0
 **/
#import "videoFrameManager.h"
#import "PeerVoiceController.h"

//! Class extension for private methods.
@interface videoFrameManager(Private)
- (void)initWithImageFrameBuffer:(NSData *)inData Manager:(SessionManager *)mgr;
@end

/**
 Manages the video frames and sends the frames in queue to the
 second party via session manager.
 **/
@implementation videoFrameManager
//! The image buffer which needs to be sent to the 2nd party.
@synthesize imageFrameBuffer = _imageFrameBuffer;
//! Gamekit session manager who will send the image data eventually.
@synthesize manager;

//! Initilizes the video manager with the frame buffer for which it's responsible
- (id)initWithImageFrameBuffer:(NSData *)inData 
                       Manager:(SessionManager *)mgr
{
	if(self == [super init])
	{
		self.imageFrameBuffer = inData;
	}
    self.manager = mgr;
	return self;
}

#pragma mark -
#pragma mark Default Methods
- (void)dealloc
{
	[_imageFrameBuffer release];
    [manager release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSOperation Methods
//! The main entry point for each queued operation
- (void)main
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self extractImageFramesFor:self.imageFrameBuffer];
	[pool release];
}

#pragma mark -
#pragma mark Image Frame Processing

//! Sends the frame buffer to the second party
- (void)extractImageFramesFor:(NSData *)inData
{
    if (self.manager == nil) return;
    // if sendImmediate is YES, there may be loss of data; but the benefit
    // is we won't have to care to accumulate all distributed packets or about
    // the order of receipt of the image packets at the receiving end.
	[self.manager sendPacket:inData ofType:PacketTypeImage sendImmediate:YES];
    //NSLog(@"Size of image: %d",[inData length]);
}

@end
