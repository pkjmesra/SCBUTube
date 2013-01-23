//
//  BluetoothViewController.h
//  SCBUTube
//
//  Created by Nikhilesh on 29/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "CustomMoviePlayerViewController.h"

@interface BluetoothViewController : UIViewController<GKPeerPickerControllerDelegate,GKSessionDelegate>{
    NSRange     range;
    NSString    *strFor;
    NSTimer     *timer;
    NSData      *movieData;
    BOOL needTosendData;
    CustomMoviePlayerViewController *moviePlayer;
}
- (IBAction)playMovieAction:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *playMovieButton;
@property(nonatomic, retain) GKPeerPickerController *peerPicker;
@property(nonatomic, retain) GKSession              *gkSession;
@property(nonatomic, retain) NSMutableArray         *peersArray;
@property(nonatomic, retain) NSString               *myPeerId;
- (void)trySendingFilesInChunk;

@end
