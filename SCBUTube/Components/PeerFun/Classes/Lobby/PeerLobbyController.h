/**
 Copyright (c) 2011, Praveen K Jha, .
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list
 of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this
 list of conditions and the following disclaimer in the documentation and/or other
 materials provided with the distribution.
 Neither the name of the . nor the names of its contributors may be
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
 File: PeerLobbyController.h
 Abstract: Lists available peers and handles the user interface related to connecting to
 a peer.
**/

#import <UIKit/UIKit.h>
#import "SessionManager.h"

//! A controller to manage the peers availability
@interface PeerLobbyController : UITableViewController <UITableViewDelegate, UITableViewDataSource, SessionManagerLobbyDelegate, UIAlertViewDelegate> {
	NSArray	*peerList;
    UIAlertView *alertView;
	SessionManager *manager;
	BOOL browseMode;
    PacketType packet;
}

//! A session manager object to send and receive messages to and from peers
@property (nonatomic,assign) BOOL browseMode;
@property (nonatomic, assign) PacketType packet;

//! A session manager object to send and receive messages to and from peers
@property (nonatomic, readonly) SessionManager *manager; 

//! A handler when the peer status changes and hance list is updated
- (void) peerListDidChange:(SessionManager *)session;
//! Pops an invitation dialog due to peer attempting to connect.
- (void) didReceiveInvitation:(SessionManager *)session 
                     fromPeer:(NSString *)participantID;
/**
 Handles the failure of invitation either because of some network issue or when peer declines the invitation.
 Display an alert sheet indicating a failure to connect to the peer.
**/
- (void) invitationDidFail:(SessionManager *)session fromPeer:(NSString *)participantID;

@end
