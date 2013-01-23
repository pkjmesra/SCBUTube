//
//  ListViewController.m
//  SCBUTube
//
//  Created by Nikhilesh on 22/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListViewController.h"
#import "DownloadsViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "VedioPlayingControllerViewController.h"

#include <ifaddrs.h>
#include <arpa/inet.h>


@interface ListViewController ()

@end

@implementation ListViewController
@synthesize table;
@synthesize datasArray;
@synthesize IPAddress;
@synthesize isBluetoothConnection;
@synthesize gkSession;
@synthesize peersArray;
@synthesize myPeerId;
@synthesize playMovieButton = _playMovieButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil manager:(SessionManager *)aManager
{
    if (self == [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        manager = [aManager retain];
        manager.listDelegate = self;
        // Custom initialization
    }
    return self;
}

- (void) sendOSInfo 
{
    int outgoing =iPhone;
#if TARGET_IPHONE_SIMULATOR
    outgoing =Simulator;
#endif
    NSData *packet = [NSData dataWithBytes: &outgoing length: sizeof(outgoing)];
    [manager sendPacket:packet ofType:PacketTypeOSInfo];
    
}

- (void) willDisconnect:(SessionManager *)session
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	//[self.navigationController popToRootViewControllerAnimated:YES];
    //	self.arViewController =nil;
   	manager.gameDelegate = nil;
	[manager release];
    manager = nil;
}

- (void) session:(SessionManager *)session didConnectAsInitiator:(BOOL)shouldStart
{
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    //! Schedule the game to update at 30fps and the call timer at 1fps.
    //! If the user is starting the voice chat, let the other party be the one
    // who starts the game.  That way both partys are starting at the same time.
    if (shouldStart) {
        if (packetsEnum == PacketTypeNSArray) {
        }
        [self sendPacket:PacketTypeStart];
        [self sendOSInfo];
        
        //! The other party started the app and has connected.
        //! Send the IP address and port information for video
    }
}

//! Send the same information each time, just with a different header
-(void) sendPacket:(PacketType)packetType
{
    Packets outgoing;
    outgoing.y[0] = CFConvertFloat32HostToSwapped(circle.bounds.origin.y);
    outgoing.x[0] = CFConvertFloat32HostToSwapped(circle.bounds.origin.x);
    NSData *packet = [[NSData alloc] initWithBytes:&outgoing length:sizeof(Packets)];
    [manager sendPacket:packet ofType:packetType];
    [packet release];
}

//! The GKSession got a packet and sent it to the game, so parse it and update state.
- (void) session:(SessionManager *)session 
didReceivePacket:(NSData*)data ofType:(PacketType)packetType
{
    Packets incoming;    
    if ([data length] == sizeof(Packets)) {
        NSLog(@"    if ([data length] == sizeof(Packets)) {");
        [data getBytes:&incoming length:sizeof(Packets)];
        switch (packetType) {
            case PacketTypeStart:
                [self sendOSInfo];
                break;
            case PacketTypeCircle:
                break;
            case PacketTypeText:
                break;
            case PacketTypeFreeHand:
                break;
            case PacketTypeTalking:
                break;
            case PacketTypeEndTalking:
                break;
            case PacketTypeMasterAccessAcquired:
                break;
            case PacketTypeImage:
                break;
            default:
                break;
        }
    }
    else if (packetType == PacketTypeVideoURL){
    }
    else if (packetType ==PacketTypeImage){
    }
    else if (packetType ==PacketTypeOSInfo){
        NSLog(@"packetType ==PacketTypeOSInfo");
        int ostype;
        [data getBytes: &ostype length: sizeof(ostype)];
    }
    else if (packetType == PacketTypeNSArray){
        self.datasArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"dataArray: %@",self.datasArray);
        IPAddress = [self.datasArray objectAtIndex:0];
        if ([IPAddress isEqualToString:@"error"])
            IPAddress = @"127.0.0.1";
        NSLog(@"recievedIP %@", IPAddress);
        [table reloadData];
    }else if (packetType == PacketTypeMovieName) {
        
        movieName = [NSKeyedUnarchiver unarchiveObjectWithData:data];         
        NSLog(@"movieName%@",movieName);
        [self trySendingFilesInChunk:movieName];
    }else if (packetType == PacketTypeMovie) {
        NSLog(@"adding data to file");
        NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [pathArray objectAtIndex:0];
        NSString *fullPathToFile = [documentsDirectory stringByAppendingPathComponent:movieName];
        NSLog(@"fullPathToFile %@",fullPathToFile);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:fullPathToFile]) {
            [fileManager createFileAtPath:fullPathToFile
                                 contents:data
                               attributes:nil];
        } else {
            [self appendToFile:fullPathToFile data:data];
        }
        NSLog(@"-------------DATA RECIEVED-------------");
    }
}

- (void) voiceChatWillStart:(SessionManager *)session{
}

- (void)trySendingFilesInChunk:(NSString *)videoName {    
    NSLog(@"Mepeer %@",self.myPeerId);
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [pathArray objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:videoName];
    movieData = [[NSData alloc] initWithContentsOfFile:path];
    NSLog(@"movieData %d",[movieData length]);
    range.length = 51200;
    range.location = 0;
    [manager sendPacket:[movieData subdataWithRange:range] ofType:PacketTypeMovie];
    timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(addData:) userInfo:nil repeats:YES];
}

-(void)addData:(NSTimer*) time
{
    BOOL fileCompleted = NO;
    range.location = range.location + range.length;
    range.length = 51200;
    NSLog(@"[movieData length] %d",[movieData length]);
    if([movieData length] < range.location+range.length){
        range.length = [movieData length] -(range.location);
        fileCompleted = YES;
    }
    NSLog(@"range Location %d, length %d",range.location, range.length);
    NSLog(@"data length %d",[[movieData subdataWithRange:range] length]);
    [manager sendPacket:[movieData subdataWithRange:range] ofType:PacketTypeMovie];
    if(fileCompleted){
        [timer invalidate];
        timer = nil;
    }
}

- (BOOL) appendToFile:(NSString *)path data:(NSData *) data{
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
        if(fileLength > 1024*1024*2/* --Byte*KB*MB-- */ && !isPlyerLoaded ){
            [self hideLoading:loadingView];
            [self loadMoviePlayer];
            isPlyerLoaded = YES;
        }
    }    
    @catch (NSException * e) {
        result = NO;
    }
    [fh closeFile];
    return result;
}

//! Gets the IP address of the first available Wi-Fi network

- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    NSLog(@"IP address is :%@",address);
    return address;
}

- (void) viewWillDisappear:(BOOL)animated{
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [manager disconnectCurrentListViewCall];
    }
    [self hideLoading:loadingView];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    isBluetoothConnection = YES;
    dataArray = [[NSMutableArray alloc] initWithObjects:[self getIPAddress], nil];
    [self createLoadingViews];
}


-(void) sendArray:(PacketType)packetType{   
    DownloadsViewController *downloadsVC = [[[DownloadsViewController alloc] init] autorelease];
    for (NSString *str in downloadsVC.listDataArray) {
        [dataArray addObject:str];
    }
    NSLog(@"dataArray: %@", dataArray);
    NSData *packet = [NSKeyedArchiver archivedDataWithRootObject:dataArray];
    [manager sendPacket:packet ofType:packetType];    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return ([self.datasArray count] -1);
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    loadingView.frame = tableView.frame;
    [self.view addSubview:loadingView];
    [self hideLoading:loadingView];

	// Configure the cell.
	cell.textLabel.text = [self.datasArray objectAtIndex:(indexPath.row+1)];//NSLocalizedString(@"YouTube", @"YouTube");
    return cell;
}

-(void) sendMovie:(PacketType)packetType{
    [manager sendPacket:subData ofType:packetType];
}

-(void) sendMovieName:(PacketType)packetType{ 
    NSData *packet = [NSKeyedArchiver archivedDataWithRootObject:movieName];
    [manager sendPacket:packet ofType:packetType];
}

- (BOOL) connectedToInternet
{
    NSString *URLString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.google.com"]];
    return ( URLString != NULL ) ? YES : NO;
}

- (void) createLoadingViews {
    CGFloat alpha = 0.5;
    loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadingView = [[UIView alloc] initWithFrame:CGRectZero];
    [loadingView setBackgroundColor:[UIColor grayColor]];
    [loadingView setAlpha:alpha];
    [loadingView addSubview:loading];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    isPlyerLoaded = NO;
    [self showLoading:loadingView];
    if (![self connectedToInternet]) {
        movieName = [self.datasArray objectAtIndex:(indexPath.row+1)];
        [self sendMovieName:PacketTypeMovieName];
    } else {
        VedioPlayingControllerViewController *videoController = [[VedioPlayingControllerViewController alloc] init];
        //! Gets the IP address of the first available Wi-Fi network
        NSString *outgoing = [NSString stringWithFormat:@"http://%@:%@/%@",IPAddress,@"12345",[self.datasArray objectAtIndex:(indexPath.row+1)]];
        NSLog(@"outgoing: %@", outgoing);
        
        [table deselectRowAtIndexPath:indexPath animated:YES];
        NSString *contentURL = [NSString stringWithString:outgoing];
        videoController.vedioURL = contentURL;
        [self.navigationController pushViewController:videoController animated:YES];
    }
}

- (void)loadMoviePlayer {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [[NSString alloc] initWithFormat:[NSString stringWithFormat:@"%@/%@",documentsDirectory, movieName]];    
	//! Create custom movie player
    moviePlayer = [[[CustomMoviePlayerViewController alloc] initWithPath:path] autorelease];    
	//! Show the movie player as modal
 	[self presentModalViewController:moviePlayer animated:YES];
	//! Prep and play the movie
    [moviePlayer readyPlayer];
}

- (void)viewDidUnload {
    loadingView = nil;
    loading = nil;
    [IPAddress release];
    [datasArray release];
    [self setTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) showLoading:(UIView *)loadingActivityView
{
    for (id subView in [loadingActivityView subviews]) {
        if ([subView isKindOfClass:[UIActivityIndicatorView class]]) {
            UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)subView;
            indicator.center = loadingActivityView.center;
            [indicator startAnimating];
        }
    }
    [loadingActivityView setHidden:NO];
}

- (void) hideLoading:(UIView *)loadingActivityView
{
    for (id subView in [loadingActivityView subviews]) {
        if ([subView isKindOfClass:[UIActivityIndicatorView class]]) {
            UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)subView;
            [indicator stopAnimating];
        }
    }
    [loadingActivityView setHidden:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [table release];
    [super dealloc];
}
@end
