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
 File: SessionManager.h
 Abstract: Manages the GKSession and GKVoiceChatService.  While the app is
 running, it transfers game packets to and from the game and the peer.

 **/

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h> 

typedef enum {
    PacketTypeVoice = 0,
    PacketTypeStart = 1,
    PacketTypeTalking = 2,
    PacketTypeEndTalking = 3,
    PacketTypeText =4,
    PacketTypeCircle=5,
    PacketTypeFreeHand =6,
    PacketTypeMasterAccessAcquired=7,
    PacketTypeMasterAccessLeft=8,
    PacketTypeImage=9,
    PacketTypeVideoURL=10,
    PacketTypeOSInfo=11
} PacketType;

typedef enum {
    ConnectionStateDisconnected,
    ConnectionStateConnecting,
    ConnectionStateConnected
} ConnectionState;

typedef enum {
    iPhone,
    Simulator
} OSTypeInfo;

@interface SessionManager : NSObject <GKSessionDelegate> {
	NSString *sessionID;
	GKSession *myGKSession;
	NSString *currentConfPeerID;
	NSMutableArray *peerList;
	id lobbyDelegate;
	id gameDelegate;
    ConnectionState sessionState;
	BOOL browseMode;
}

@property BOOL browseMode;
//! Gets or sets the current peer id of the connected peer
@property (nonatomic, readonly) NSString *currentConfPeerID;
//! Gets or sets the peer list
@property (nonatomic, readonly) NSMutableArray *peerList;
@property (nonatomic, assign) id lobbyDelegate;
@property (nonatomic, assign) id gameDelegate;

- (void) setupSession;
- (void) connect:(NSString *)peerID;
- (BOOL) didAcceptInvitation;
- (void) didDeclineInvitation;
- (void) sendPacket:(NSData*)data ofType:(PacketType)type;
- (void) sendPacket:(NSData*)data 
             ofType:(PacketType)type 
      sendImmediate:(BOOL)unReliable;
- (void) disconnectCurrentCall;
- (NSString *) displayNameForPeer:(NSString *)peerID;

@end

//! Class extension for private methods.
@interface SessionManager ()

- (BOOL) comparePeerID:(NSString*)peerID;
- (BOOL) isReadyToStart;
- (void) voiceChatDidStart;
- (void) destroySession;
- (void) willTerminate:(NSNotification *)notification;
- (void) willResume:(NSNotification *)notification;

@end

@interface SessionManager (VoiceManager) <GKVoiceChatClient>

- (void) setupVoice;

@end

//! A protocol contract to receive the peer list/status change events
@protocol SessionManagerLobbyDelegate

- (void) peerListDidChange:(SessionManager *)session;
- (void) didReceiveInvitation:(SessionManager *)session 
                     fromPeer:(NSString *)participantID;
- (void) invitationDidFail:(SessionManager *)session 
                  fromPeer:(NSString *)participantID;

@end

//! A protocol contract to receive the voice chat events
@protocol SessionManagerGameDelegate

- (void) voiceChatWillStart:(SessionManager *)session;
- (void) session:(SessionManager *)session 
didConnectAsInitiator:(BOOL)shouldStart;
- (void) willDisconnect:(SessionManager *)session;
- (void) session:(SessionManager *)session 
didReceivePacket:(NSData*)data 
          ofType:(PacketType)packetType;

@end

