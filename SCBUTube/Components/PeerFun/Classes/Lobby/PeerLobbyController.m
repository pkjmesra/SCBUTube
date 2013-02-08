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
 File: PeerLobbyController.m
 Abstract: Lists available peers and handles the user interface related to connecting to
 a peer.
**/

#import "PeerLobbyController.h"
#import "PeerVoiceController.h"
#import <GameKit/GameKit.h> 
#import "ListViewController.h"

//! A controller to manage the peers availability
@implementation PeerLobbyController
@synthesize manager;
@synthesize browseMode;
@synthesize packet;

#pragma mark View Controller Methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
    manager = [[SessionManager alloc] init];
    [manager getList:packet];
    manager.lobbyDelegate = self;
//    manager.listDelegate = self;
	manager.browseMode = self.browseMode;
    [manager setupSession];
    
	[self peerListDidChange:nil];
}

-(void)viewDidUnload
{
	[super viewDidUnload];
	[manager destroySession];
	manager.lobbyDelegate = nil;
}

- (void)dealloc 
{
    manager.lobbyDelegate = nil;
    [manager release];
	[peerList release];
	[alertView release];
    [super dealloc];
}

#pragma mark -
#pragma mark Opening Method
//! Called when user selects a peer from the list or accepts a call invitation.
- (void) openListWithPeerID:(NSString *)peerID
{
	ListViewController *listScreen = [[ListViewController alloc]
                                        initWithNibName:@"ListViewController"
                                        bundle:nil
                                        manager: manager];
	[self.navigationController pushViewController:listScreen animated:YES];
	[listScreen release];
}
//! Called when user selects a peer from the list or accepts a call invitation.
- (void) openGameScreenWithPeerID:(NSString *)peerID
{
	PeerVoiceController *gameScreen = [[PeerVoiceController alloc]
                                       initWithNibName:@"PictureInPictureViewController"
                                       bundle:nil
                                       manager: manager];
    gameScreen.packetsEnum = packet;
	[self.navigationController pushViewController:gameScreen animated:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	[gameScreen release];
}


#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [peerList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	static NSString *TopLevelCellIdentifier = @"TopLevelCellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TopLevelCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero
                                       reuseIdentifier:TopLevelCellIdentifier] autorelease];
	}

	NSUInteger row = [indexPath row];
	
	cell.textLabel.text = [manager displayNameForPeer:[peerList objectAtIndex:row]]; 
	return cell;
}

#pragma mark Table View Delegate Methods

//! The user selected a peer from the list to connect to.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[manager connect:[peerList objectAtIndex:[indexPath row]]]; 
    if (packet == PacketTypeNSArray) 
        [self openListWithPeerID:[peerList objectAtIndex:[indexPath row]]];
    else 
        [self openGameScreenWithPeerID:[peerList objectAtIndex:[indexPath row]]]; 
    
}

#pragma mark -
#pragma mark GameSessionLobbyDelegate Methods
//! A handler when the peer status changes and hance list is updated
- (void) peerListDidChange:(SessionManager *)session;
{
    NSArray *tempList = peerList;
	peerList = [session.peerList copy];
    [tempList release];
	[self.tableView reloadData]; 
}

//! Pops an invitation dialog due to peer attempting to connect.
- (void) didReceiveInvitation:(SessionManager *)session fromPeer:(NSString *)participantID;
{
	if ([participantID hasSuffix:@"~Browser~"])
	{
		// Accept the invite
		[manager didAcceptInvitation];
		// Send the root folder list of videos/directories
	}
	else
	{
		NSString *str = [NSString stringWithFormat:@"Incoming Invite from %@", participantID];
		if (alertView.visible) {
			[alertView dismissWithClickedButtonIndex:0 animated:NO];
			[alertView release];
		}
		alertView = [[UIAlertView alloc] 
					 initWithTitle:str
					 message:@"Do you wish to accept?" 
					 delegate:self 
					 cancelButtonTitle:@"Decline" 
					 otherButtonTitles:nil];
		[alertView addButtonWithTitle:@"Accept"]; 
		[alertView show];
	}
}

/**
 Handles the failure of invitation either because of some network issue or when peer declines the invitation.
 Display an alert sheet indicating a failure to connect to the peer.
 **/
- (void) invitationDidFail:(SessionManager *)session fromPeer:(NSString *)participantID
{
    NSString *str;
    if (alertView.visible) {
        // Peer cancelled invitation before it could be accepted/rejected
        // Close the invitation dialog before opening an error dialog
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
        [alertView release];
        str = [NSString stringWithFormat:@"%@ cancelled call", participantID]; 
    } else {
        // Peer rejected invitation or exited app.
        str = [NSString stringWithFormat:@"%@ declined your call", participantID]; 
    }
    
    alertView = [[UIAlertView alloc] initWithTitle:str message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark -
#pragma mark UIAlertViewDelegate Methods

//! User has reacted to the dialog box and chosen accept or reject.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
        // User accepted.  Open the game screen and accept the connection.
        if ([manager didAcceptInvitation]){
            if (packet == PacketTypeNSArray) 
                [self openListWithPeerID:manager.currentConfPeerID];
            else 
                [self openGameScreenWithPeerID:manager.currentConfPeerID]; 
        }
	} else {
        [manager didDeclineInvitation];
	}
}

@end
