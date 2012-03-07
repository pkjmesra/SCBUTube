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
 videoFrameManager.h
 PeerFun
 Abstract:  Manages the video frames and sends the frames in queue to the
            second party via session manager.
 Version: 1.0
**/

#import <Foundation/Foundation.h>
#import "SessionManager.h"
/**
 Manages the video frames and sends the frames in queue to the
 second party via session manager.
 **/
@interface videoFrameManager : NSOperation {

	@private
	NSData *_imageFrameBuffer;
    SessionManager *manager; 
}
//! The image buffer which needs to be sent to the 2nd party.
@property(nonatomic,retain) NSData *imageFrameBuffer;
//! Gamekit session manager who will send the image data eventually.
@property(nonatomic,retain) SessionManager *manager;

//! Initilizes the video manager with the frame buffer for which it's responsible
- (id)initWithImageFrameBuffer:(NSData *)inData 
                       Manager:(SessionManager *)mgr;

@end

//! Class extension for private methods.
@interface videoFrameManager ()
//! Sends the frame buffer to the second party
- (void)extractImageFramesFor:(NSData *)inData;
@end