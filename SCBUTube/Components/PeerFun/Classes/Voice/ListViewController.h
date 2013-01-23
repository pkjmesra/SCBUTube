//
//  ListViewController.h
//  SCBUTube
//
//  Created by Nikhilesh on 22/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionManager.h"
#import <GameKit/GameKit.h>
#import "CustomMoviePlayerViewController.h"

typedef struct {
    CGRect bounds;
} Circles;

typedef struct {
    CFSwappedFloat32    x[10];
    CFSwappedFloat32    y[10];
    CFSwappedFloat32    dimension[10];
} Packets;

@interface ListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, SessionManagerlistDelegate>{
    SessionManager *manager; 
    NSMutableArray *dataArray;
    PacketType packetsEnum;
    Circles circle;
    NSArray *datasArray;
    NSString *IPAddress;
    NSRange     range;
    NSString    *strFor;
    NSTimer     *timer;
    NSData      *movieData;
    BOOL needTosendData;
    CustomMoviePlayerViewController *moviePlayer;
    NSData *subData;
    NSString *movieName;
    BOOL isPacketMovieName;
    BOOL isPlyerLoaded;
    UIView *loadingView;
    UIActivityIndicatorView *loading;
}
//! Bluetooth
@property (retain, nonatomic) IBOutlet UIButton *playMovieButton;
@property(nonatomic, retain) GKSession              *gkSession;
@property(nonatomic, retain) NSMutableArray         *peersArray;
@property(nonatomic, retain) NSString               *myPeerId;
@property (assign, nonatomic) BOOL isBluetoothConnection;
@property (retain, nonatomic) NSString *IPAddress;
@property (retain, nonatomic) NSArray *datasArray;
@property (retain, nonatomic) IBOutlet UITableView *table;
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil manager:(SessionManager *)aManager;
- (void) session:(SessionManager *)session didConnectAsInitiator:(BOOL)shouldStart;
- (void) session:(SessionManager *)session didReceivePacket:(NSData*)data ofType:(PacketType)packetType;
- (void)trySendingFilesInChunk:(NSString *)videoName;
@end
