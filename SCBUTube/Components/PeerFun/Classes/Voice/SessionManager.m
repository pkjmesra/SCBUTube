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
 File: SessionManager.m
 Abstract: Manages the GKSession and GKVoiceChatService.  While the app is
 running, it transfers game packets to and from the game and the peer.
 
 **/

#import <AudioToolbox/AudioToolbox.h>
#import "SessionManager.h"

#define SESSION_ID @"PeerVoice"

@implementation SessionManager
@synthesize currentConfPeerID;
@synthesize peerList;
@synthesize lobbyDelegate;
@synthesize gameDelegate;
@synthesize browseMode;
@synthesize listDelegate;
@synthesize isDownLoadingMovie;

#pragma mark -
#pragma mark NSObject Methods

- (id)init 
{
	if (self == [super init]) {
        // Peers need to have the same sessionID set on their GKSession to see each other.
		sessionID = SESSION_ID; 
		peerList = [[NSMutableArray alloc] init];
        
        // Set up starting/stopping session on application hiding/terminating
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willTerminate:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willTerminate:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willResume:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
	}
	return self;  
}
-(void) getList:(PacketType)packet{
    packetInfo = packet;
    if (!(packetInfo == PacketTypeNSArray || packetInfo == PacketTypeMovieName || packetInfo == PacketTypeMovie)) 
        [self setupVoice];
    NSLog(@"packetInfo: %d", packetInfo);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [GKVoiceChatService defaultVoiceChatService].client = nil;
    if (myGKSession) [self destroySession];
	myGKSession = nil;
	sessionID = nil; 
	[peerList release]; 
    [super dealloc];
}

#pragma mark -
#pragma mark Session logic

//! Creates a GKSession and advertises availability to Peers
- (void) setupSession
{
	UIDevice *device =[UIDevice currentDevice];
	// GKSession will default to using the device name as the display name
	NSString *name =[NSString stringWithFormat:@"%@-%@-%@-%@",[device name],[device model],[device systemName],[device systemVersion]];
	if (browseMode)
		name = [NSString stringWithFormat:@"%@%@",name,@"~Browser~"];
	myGKSession = [[GKSession alloc] initWithSessionID:sessionID displayName:name sessionMode:GKSessionModePeer];
	myGKSession.delegate = self; 
	[myGKSession setDataReceiveHandler:self withContext:nil]; 
	myGKSession.available = YES;
    sessionState = ConnectionStateDisconnected;
    [lobbyDelegate peerListDidChange:self];
}

//! Initiates a GKSession connection to a selected peer.
-(void) connect:(NSString *) peerID
{
	[myGKSession connectToPeer:peerID withTimeout:10.0];
    currentConfPeerID = [peerID retain];
    sessionState = ConnectionStateConnecting;
}

//! Called from PeerLobbyController if the user accepts the invitation alertView
-(BOOL) didAcceptInvitation
{
    NSError *error = nil;
    if (![myGKSession acceptConnectionFromPeer:currentConfPeerID error:&error]) {
        NSLog(@"%@",[error localizedDescription]);
    }
    
    return (gameDelegate == nil);
}

//! Called from PeerLobbyController if the user declines the invitation alertView
-(void) didDeclineInvitation
{
    // Deny the peer.
    if (sessionState != ConnectionStateDisconnected) {
        [myGKSession denyConnectionFromPeer:currentConfPeerID];
		[currentConfPeerID release];
        currentConfPeerID = nil;
        sessionState = ConnectionStateDisconnected;
    }
    // Go back to the lobby if the game screen is open.
    [gameDelegate willDisconnect:self];
}

-(BOOL) comparePeerID:(NSString*)peerID
{
    return [peerID compare:myGKSession.peerID] == NSOrderedAscending;
}

//! Called to check if the session is ready to start a voice chat.
-(BOOL) isReadyToStart
{
    return sessionState == ConnectionStateConnected;
}

//! When the voice chat starts, tell the game it can begin.
-(void) voiceChatDidStart
{
    [gameDelegate session:self didConnectAsInitiator:![self comparePeerID:currentConfPeerID]];
}


//! Called when voice or game data is received over the network from the peer
- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context
{
    PacketType header;    
    NSLog(@"receiveData for not movie");        
    uint32_t swappedHeader;
    if ([data length] >= sizeof(uint32_t)) {
        [data getBytes:&swappedHeader length:sizeof(uint32_t)];
        header = (PacketType)CFSwapInt32BigToHost(swappedHeader);
        NSRange payloadRange = {sizeof(uint32_t), [data length]-sizeof(uint32_t)};
        NSData* payload = [data subdataWithRange:payloadRange];
        NSLog(@"loading data for %d",header);
        // Check the header to see if this is a voice
        if (header == PacketTypeVoice) {
            [[GKVoiceChatService defaultVoiceChatService] receivedData:payload fromParticipantID:peer];
        } else if (header == PacketTypeNSArray || header == PacketTypeMovieName || header == PacketTypeMovie) {
            [listDelegate session:self didReceivePacket:payload ofType:header];
        }
        else {
            [gameDelegate session:self didReceivePacket:payload ofType:header];
        }
    }
}


//! Called by VoiceController and VoiceManager to send data to the peer
-(void) sendPacket:(NSData*)data ofType:(PacketType)type
{
    NSError *error;
    NSLog(@"sendPacket data for non Movie");         
    NSMutableData * newPacket = [NSMutableData dataWithCapacity:([data length]+sizeof(uint32_t))];
    // Both game and voice data is prefixed with the PacketType so the peer knows where to send it.
    uint32_t swappedType = CFSwapInt32HostToBig((uint32_t)type);
    [newPacket appendBytes:&swappedType length:sizeof(uint32_t)];
    [newPacket appendData:data];
    
    if (currentConfPeerID) {
        if (![myGKSession sendData:newPacket
                           toPeers:[NSArray arrayWithObject:currentConfPeerID]
                      withDataMode:GKSendDataReliable error:&error])
        {
            NSLog(@"%@",[error localizedDescription]);
        }
        NSLog(@"IP address Packet sent to Peer");
    }    
}

//! Called by VoiceController and VoiceManager to send data to the peer
-(void) sendPacket:(NSData*)data ofType:(PacketType)type sendImmediate:(BOOL)unReliable
{
    
    NSMutableData * newPacket = [NSMutableData dataWithCapacity:([data length]+sizeof(uint32_t))];
    // Both game and voice data is prefixed with the PacketType so the peer knows where to send it.
    uint32_t swappedType = CFSwapInt32HostToBig((uint32_t)type);
    [newPacket appendBytes:&swappedType length:sizeof(uint32_t)];
    [newPacket appendData:data];
    NSError *error;
    GKSendDataMode mode = unReliable?GKSendDataUnreliable:GKSendDataReliable;
    if (currentConfPeerID) {
        if (![myGKSession sendData:newPacket toPeers:[NSArray arrayWithObject:currentConfPeerID] withDataMode:mode error:&error]) {
            NSLog(@"%@",[error localizedDescription]);
        }
    }
}


-(void) disconnectCurrentListViewCall
{	
    
    [listDelegate willDisconnect:self];
    if (sessionState != ConnectionStateDisconnected) {
        if(sessionState == ConnectionStateConnected) {		
            [[GKVoiceChatService defaultVoiceChatService] stopVoiceChatWithParticipantID:currentConfPeerID];
        }
        // Don't leave a peer hangin'
        if (sessionState == ConnectionStateConnecting) {
            [myGKSession cancelConnectToPeer:currentConfPeerID];
        }
        [myGKSession disconnectFromAllPeers];
        myGKSession.available = YES;
        sessionState = ConnectionStateDisconnected;
		[currentConfPeerID release];
        currentConfPeerID = nil;
    }
}



//! Clear the connection states in the event of leaving a call or error.
-(void) disconnectCurrentCall
{	
    
    [gameDelegate willDisconnect:self];
    if (sessionState != ConnectionStateDisconnected) {
        if(sessionState == ConnectionStateConnected) {		
            [[GKVoiceChatService defaultVoiceChatService] stopVoiceChatWithParticipantID:currentConfPeerID];
        }
        // Don't leave a peer hangin'
        if (sessionState == ConnectionStateConnecting) {
            [myGKSession cancelConnectToPeer:currentConfPeerID];
        }
        [myGKSession disconnectFromAllPeers];
        myGKSession.available = YES;
        sessionState = ConnectionStateDisconnected;
		[currentConfPeerID release];
        currentConfPeerID = nil;
    }
}

//! Application is exiting or becoming inactive, end the session.
- (void)destroySession
{
    [self disconnectCurrentCall];
	myGKSession.delegate = nil;
	[myGKSession setDataReceiveHandler:nil withContext:nil];
	[myGKSession release];
    [peerList removeAllObjects];
}

//! Called when notified the application is exiting or becoming inactive.
- (void)willTerminate:(NSNotification *)notification
{
    [self destroySession];
}

//! Called after the app comes back from being hidden by something like a phone call.
- (void)willResume:(NSNotification *)notification
{
    [self setupSession];
}

#pragma mark -
#pragma mark GKSessionDelegate Methods and Helpers

//! Received an invitation.  If we aren't already connected to someone, open the invitation dialog.
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    if (sessionState == ConnectionStateDisconnected) {
        currentConfPeerID = [peerID retain];
        sessionState = ConnectionStateConnecting;
        [lobbyDelegate didReceiveInvitation:self fromPeer:[myGKSession displayNameForPeer:peerID]];
    } else {
        [myGKSession denyConnectionFromPeer:peerID];
    }
}

//! Unable to connect to a session with the peer, due to rejection or exiting the app
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    NSLog(@"%@",[error localizedDescription]);
    if (sessionState != ConnectionStateDisconnected) {
        [lobbyDelegate invitationDidFail:self fromPeer:[myGKSession displayNameForPeer:peerID]];
        // Make self available for a new connection.
		[currentConfPeerID release];
        currentConfPeerID = nil;
        myGKSession.available = YES;
        sessionState = ConnectionStateDisconnected;
    }
}

//! The running session ended, potentially due to network failure.
- (void)session:(GKSession *)session didFailWithError:(NSError*)error
{
    NSLog(@"%@",[error localizedDescription]);
    [self disconnectCurrentCall];
}

//! React to some activity from other peers on the network.
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    //	NSLog(@"myGKSession.peerID :%@",myGKSession.peerID);
    //	NSLog(@"Incoming peerID :%@",peerID);
	
	if (![myGKSession.peerID isEqualToString:peerID])
	{
		switch (state) { 
			case GKPeerStateAvailable:
				// A peer became available by starting app, exiting settings, or ending a call.
				if (![peerList containsObject:peerID]) {
					[peerList addObject:peerID]; 
				}
				[lobbyDelegate peerListDidChange:self]; 
				break;
			case GKPeerStateUnavailable:
				// Peer unavailable due to joining a call, leaving app, or entering settings.
				[peerList removeObject:peerID]; 
				[lobbyDelegate peerListDidChange:self]; 
				break;
			case GKPeerStateConnected:
				// Connection was accepted, set up the voice chat.
				currentConfPeerID = [peerID retain];
				myGKSession.available = NO;
				[gameDelegate voiceChatWillStart:self];
				sessionState = ConnectionStateConnected;
                if (packetInfo == PacketTypeNSArray){
                    [listDelegate sendArray:packetInfo];
                }else if (packetInfo == PacketTypeMovieName) {
                    [listDelegate sendMovieName:packetInfo];
                }else if (packetInfo == PacketTypeMovie) {
                    [listDelegate sendMovie:packetInfo];
                }
                else {
                    // Compare the IDs to decide which device will invite the other to a voice chat.
                    
                    if([self comparePeerID:peerID]) {
                        NSError *error; 
                        if (![[GKVoiceChatService defaultVoiceChatService] startVoiceChatWithParticipantID:peerID error:&error]) {
                            NSLog(@"%@",[error localizedDescription]);
                        }
                    }
                }
                
				break;				
			case GKPeerStateDisconnected:
				// The call ended either manually or due to failure somewhere.
				[self disconnectCurrentCall];
				[peerList removeObject:peerID]; 
				[lobbyDelegate peerListDidChange:self];
				break;
			case GKPeerStateConnecting:
				// Peer is attempting to connect to the session.
				break;
			default:
				break;
		}
	}
}


- (NSString *) displayNameForPeer:(NSString *)peerID
{
	return [myGKSession displayNameForPeer:peerID];
}

@end

#pragma mark -
#pragma mark AudioSession Setup

//! Sets up the audio session to use the speakerphone
void EnableSpeakerPhone ()
{
	UInt32 dataSize = sizeof(CFStringRef);
	CFStringRef currentRoute = NULL;
    OSStatus result = noErr;
    
	AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &dataSize, &currentRoute);
    
	// Set the category to use the speakers and microphone.
    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
    result = AudioSessionSetProperty (
                                      kAudioSessionProperty_AudioCategory,
                                      sizeof (sessionCategory),
                                      &sessionCategory
                                      );	
    assert(result == kAudioSessionNoError);
    
    Float64 sampleRate = 44100.0;
    dataSize = sizeof(sampleRate);
    result = AudioSessionSetProperty (
                                      kAudioSessionProperty_PreferredHardwareSampleRate,
                                      dataSize,
                                      &sampleRate
                                      );
    assert(result == kAudioSessionNoError);
    
	// Default to speakerphone if a headset isn't plugged in.
    UInt32 route = kAudioSessionOverrideAudioRoute_Speaker;
    dataSize = sizeof(route);
    result = AudioSessionSetProperty (
                                      // This requires iPhone OS 3.1
                                      kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                                      dataSize,
                                      &route
                                      );
    assert(result == kAudioSessionNoError);
    
    AudioSessionSetActive(YES);
}

/**
 Called when audio is interrupted by a call or alert.  Since we are using
 UIApplicationWillResignActiveNotification to deal with ending the game,
 this just resumes speakerphone after an audio interruption.
 **/
void InterruptionListenerCallback (void *inUserData, UInt32 interruptionState)
{
    if (interruptionState == kAudioSessionEndInterruption) {
        EnableSpeakerPhone();
    }
}

@implementation SessionManager (VoiceManager)

- (void)setupVoice
{
    // Set up audio to default to speakerphone but use the headset if one is plugged in.
    AudioSessionInitialize(NULL, NULL, InterruptionListenerCallback, self);
    EnableSpeakerPhone();
    
    [GKVoiceChatService defaultVoiceChatService].client = self; 
	[[GKVoiceChatService defaultVoiceChatService] setInputMeteringEnabled:YES]; 
	[[GKVoiceChatService defaultVoiceChatService] setOutputMeteringEnabled:YES];
}

//! GKVoiceChatService Client Method. For convenience, we are using the same ID for the GKSession and GKVoiceChatService.
- (NSString *)participantID
{
	return myGKSession.peerID;
}

//! GKVoiceChatService Client Method. Sends voice data over the GKSession to the peer.
- (void)voiceChatService:(GKVoiceChatService *)voiceChatService sendData:(NSData *)data toParticipantID:(NSString *)participantID
{
  	[self sendPacket:data ofType:PacketTypeVoice]; 
}

//! GKVoiceChatService Client Method. Received a voice chat invitation from the connected peer.
- (void)voiceChatService:(GKVoiceChatService *)voiceChatService didReceiveInvitationFromParticipantID:(NSString *)participantID callID:(NSInteger)callID
{
	if ([self isReadyToStart]) {
		NSError *error;
		if (![[GKVoiceChatService defaultVoiceChatService] acceptCallID:callID error:&error]) {
            NSLog(@"%@",[error localizedDescription]);
            [self disconnectCurrentCall];
        }
	} else {
		[[GKVoiceChatService defaultVoiceChatService] denyCallID:callID];
		[self disconnectCurrentCall];
	}
}

//! GKVoiceChatService Client Method. In the event something weird happened and the voice chat failed, disconnect.
- (void)voiceChatService:(GKVoiceChatService *)voiceChatService didNotStartWithParticipantID:(NSString *)participantID error:(NSError *)error
{
    NSLog(@"%@",[error localizedDescription]);
    [self disconnectCurrentCall];
}

//! GKVoiceChatService Client Method. The voice chat with the connected peer successfully started.
- (void)voiceChatService:(GKVoiceChatService *)voiceChatService didStartWithParticipantID:(NSString *)participantID
{
    // Since the session and voice chat are up, we can tell the game to start.
    [self voiceChatDidStart]; 
}

@end
