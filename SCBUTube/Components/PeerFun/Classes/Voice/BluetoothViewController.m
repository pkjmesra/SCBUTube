//
//  BluetoothViewController.m
//  SCBUTube
//
//  Created by Nikhilesh on 29/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BluetoothViewController.h"

@interface BluetoothViewController ()

@end

@implementation BluetoothViewController
@synthesize peerPicker;
@synthesize gkSession;
@synthesize peersArray;
@synthesize myPeerId;
@synthesize playMovieButton = _playMovieButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.peerPicker = [[GKPeerPickerController alloc] init];
    self.peerPicker.delegate = self;
    self.peersArray = [[NSMutableArray alloc] init];
    needTosendData = YES;
    [self.playMovieButton setEnabled:NO];
    [self.playMovieButton setHidden:YES];
}

- (void)viewDidUnload
{
    [self setPlayMovieButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma 
#pragma mark - IBAction
- (IBAction)OnBluetooth:(id)sender 
{
    self.peerPicker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    [self.peerPicker show];
}

#pragma mark -
#pragma mark GKPeerPickerControllerDelegate

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker 
           sessionForConnectionType:(GKPeerPickerConnectionType)type
{
    GKSession *session = [[GKSession alloc] initWithSessionID:@"com.GL" 
                                                  displayName:nil 
                                                  sessionMode:GKSessionModePeer];
    session.delegate = self;
    return [session autorelease];
}

- (void)peerPickerController:(GKPeerPickerController *)picker 
              didConnectPeer:(NSString *)peerID 
                   toSession:(GKSession *)session
{
    
    self.gkSession = session;
    self.gkSession.delegate = self;
    
    picker.delegate = nil;
    [picker dismiss];
    [picker autorelease];
}

- (void)receiveData:(NSData *)data 
           fromPeer:(NSString *)peer 
          inSession: (GKSession *)session 
            context:(void *)context
{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [pathArray objectAtIndex:0];
    NSString *fullPathToFile = [documentsDirectory stringByAppendingPathComponent:@"Movie12.mp4"];
    NSLog(@"fullPathToFile %@",fullPathToFile);
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:fullPathToFile])
    {
        [manager createFileAtPath:fullPathToFile
                         contents:data
                       attributes:nil];
    }
    else
    {
        [self appendToFile:fullPathToFile data:data];
    }
    
    NSLog(@"-------------DATA RECIEVED-------------");
    
}

#pragma mark -
#pragma mark GKSessionDelegate


- (void)session:(GKSession *)session 
           peer:(NSString *)peerID 
 didChangeState:(GKPeerConnectionState)state
{
    NSLog(@"state %d",state);
    if(state == GKPeerStateConnected)
    {
        [session setDataReceiveHandler:self withContext:nil];
        self.gkSession = session;
        self.myPeerId = peerID;
        //        [self trySendingFilesInChunk];
        
    }
    
}
- (BOOL)acceptConnectionFromPeer:(NSString *)peerID error:(NSError **)error
{
    self.myPeerId = peerID;
    //    if(needTosendData)
    //        [self trySendingFilesInChunk];
    NSLog(@"------sending data----------");
    
    return YES;
}
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    NSLog(@"- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID");
    self.myPeerId = peerID;
    //    [self trySendingFilesInChunk];
    //    NSLog(@"------sending data----------");
}

- (void)trySendingFilesInChunk {    
    NSLog(@"Mepeer %@",self.myPeerId);
    NSString *path = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp4"];
    
    movieData = [[NSData alloc] initWithContentsOfFile:path];
    
    NSLog(@"movieData %d",[movieData length]);
    
    range.length = 20480;
    range.location = 0;
    NSData *subData = [movieData subdataWithRange:range];
    
    [self.gkSession sendData:subData
                     toPeers:[NSArray arrayWithObjects:self.myPeerId, nil]
                withDataMode:GKSendDataReliable
                       error:nil];
    
    //    NSFileManager *fm = [NSFileManager defaultManager];
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *documentsDirectory = [paths objectAtIndex:0];
    //    strFor = [[NSString alloc] initWithFormat:@"%@/Movie.mp4",documentsDirectory];
    //    NSLog(@"strFor %@",strFor);
    //    BOOL returnCode = [fm createFileAtPath:strFor contents:subData attributes:nil];
    //    NSLog(@"returnCode %d",returnCode);
    //    NSLog(@"movieData %d",[movieData length]);
    timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(addData:) userInfo:nil repeats:YES];
    
}



-(void)addData:(NSTimer*) time
{
    BOOL fileCompleted = NO;
    range.location = range.location + range.length;
    range.length = 20480;
    NSLog(@"[movieData length] %d",[movieData length]);
    if([movieData length] < range.location+range.length)
    {
        range.length = [movieData length] -(range.location);
        fileCompleted = YES;
    }
    NSLog(@"range Location %d, length %d",range.location, range.length);
    NSLog(@"data length %d",[[movieData subdataWithRange:range] length]);
    
    [self.gkSession sendData:[movieData subdataWithRange:range]
                     toPeers:[NSArray arrayWithObjects:self.myPeerId, nil]
                withDataMode:GKSendDataReliable
                       error:nil];
    
    //[self appendToFile:strFor data:[movieData subdataWithRange:range]];
    //[[movieData subdataWithRange:range] writeToFile:strFor atomically:YES];
    if(fileCompleted)
    {
        [timer invalidate];
        timer = nil;
    }
    
}



- (BOOL) appendToFile:(NSString *)path data:(NSData *) data
{
    BOOL result = YES;
    NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:path];
    if ( !fh ) {
        
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        
        fh = [NSFileHandle fileHandleForWritingAtPath:path];
        
    }
    if ( !fh ) return NO;
    @try {
        
        [fh seekToEndOfFile];
        [fh writeData:data];
        NSInteger fileLength = [fh offsetInFile];
        NSLog(@"file length %d",fileLength);
        if(![self.playMovieButton isEnabled] && fileLength > 7000000)
        {
            [self.playMovieButton setEnabled:YES];
            [self.playMovieButton setHidden:NO];
        }
    }
    
    
    @catch (NSException * e) {
        result = NO;
    }
    [fh closeFile];
    return result;
    
}

- (void)loadMoviePlayer
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [[NSString alloc] initWithFormat:@"%@/Movie12.mp4",documentsDirectory];
	// Play movie from the bundle
    //  NSString *path = [[NSBundle mainBundle] pathForResource:@"Movie-1" ofType:@"mp4" inDirectory:nil];
    
	// Create custom movie player
    moviePlayer = [[[CustomMoviePlayerViewController alloc] initWithPath:path] autorelease];
    
    
	// Show the movie player as modal
 	[self presentModalViewController:moviePlayer animated:YES];
    
	// Prep and play the movie
    [moviePlayer readyPlayer];
}

- (void)dealloc {
    [_playMovieButton release];
    [super dealloc];
}
- (IBAction)playMovieAction:(id)sender {
    [self loadMoviePlayer];
}

@end
