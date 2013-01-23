/**
 Copyright (c) 2011, Praveen K Jha, Research2Development Inc.
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
 PeerVoiceController.h
 PeerFun
 Abstract: Controls the logic, controls, networking, and view of the actual game.
 Version: 1.0
 **/
#import <UIKit/UIKit.h>
#import "SessionManager.h"
#import "CollaborationView.h"
#import "PictureInPictureViewController.h"
typedef struct {
    CGRect bounds;
} Circle;

typedef struct {
    CFSwappedFloat32    x[10];
    CFSwappedFloat32    y[10];
    CFSwappedFloat32    dimension[10];
} Packet;

//! Controls the logic, controls, networking, and view of the actual game.
@interface PeerVoiceController : PictureInPictureViewController <SessionManagerGameDelegate> {
	IBOutlet UILabel *stateLabel;
	IBOutlet UILabel *callTimerLabel;

	NSTimeInterval startTime;
	NSTimer *callTimer;

    CollaborationView *collabView;
	SessionManager *manager; 
    Circle circle;
    id arViewController;
    
    BOOL partyTalking;
    BOOL enemyTalking;
    BOOL isMaster;
    BOOL _running;
	NSOperationQueue *_operationQueue;
    NSTimeInterval frameskipTimestamp;
    NSArray *dataArray;
    PacketType packetsEnum;
}
@property (nonatomic, assign) PacketType packetsEnum;

//! Sets the connection status label
@property (nonatomic, retain) UILabel *stateLabel;
//! Gets or sets the view controller for AR view
@property (nonatomic,retain)  id arViewController;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil manager:(SessionManager *)aManager;
- (void) voiceChatWillStart:(SessionManager *)session;
- (void) session:(SessionManager *)session didConnectAsInitiator:(BOOL)shouldStart;
- (void) willDisconnect:(SessionManager *)session;
- (void) session:(SessionManager *)session didReceivePacket:(NSData*)data ofType:(PacketType)packetType;

@end

// Class extension for private methods.
@interface PeerVoiceController ()
//! Update the call timer once a second.
- (void) updateElapsedTime:(NSTimer *) timer;
//! Called when the user hits the end call toolbar button.
- (void) endButtonHit;
//! Send the same information each time, just with a different header
- (void) sendPacket:(PacketType)packetType;
//! Grants master/screen share access if specified |toSelf| is YES
- (void)grantMasterAccess:(BOOL)toSelf;
//! Begins sharing the screen with second party
- (void)beginShare;
//! Launches the sharing screen and starts streaming
- (void)openARScreen;
//! starts streaming the image data to 2nd party
- (void)startStreaming;
//! Begins screen capture on a separate thread
- (void)threadedCaptureScreen;
//! Captures screen and puts the captured screen into a new operation queue
- (void)captureScreen;
//! Sends the video URL to the second party
- (void)sendVideoURL;
//! Gets the IP address of the first available Wi-Fi network
- (NSString *)getIPAddress;
@end
