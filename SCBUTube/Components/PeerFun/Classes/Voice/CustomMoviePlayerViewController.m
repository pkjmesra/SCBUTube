//
//  CustomMoviePlayerViewController.m
//
//  Copyright iOSDeveloperTips.com All rights reserved.
//

#import "CustomMoviePlayerViewController.h"

#pragma mark -
#pragma mark Compiler Directives & Static Variables

@implementation CustomMoviePlayerViewController

/*---------------------------------------------------------------------------
 * 
 *--------------------------------------------------------------------------*/
- (id)initWithPath:(NSString *)moviePath
{
	// Initialize and create movie URL
    if (self = [super init])
    {
        movieURL = [NSURL fileURLWithPath:moviePath];    
        NSLog(@"movieURL %@",movieURL);
        [movieURL retain];
        i = 20;
        
    }
	return self;
}

/*---------------------------------------------------------------------------
 * For 3.2 and 4.x devices
 * For 3.1.x devices see moviePreloadDidFinish:
 *--------------------------------------------------------------------------*/
- (void) moviePlayerLoadStateChanged:(NSNotification*)notification 
{
	// Unless state is unknown, start playback
    if ([mp loadState] != MPMovieLoadStateUnknown)
    {
        // Remove observer
        [[NSNotificationCenter 	defaultCenter] removeObserver:self
                                                         name:MPMoviePlayerLoadStateDidChangeNotification 
                                                       object:nil];
        
        // When tapping movie, status bar will appear, it shows up
        // in portrait mode by default. Set orientation to landscape
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
        
        // Rotate the view for landscape playback
        [[self view] setBounds:CGRectMake(0, 0, 480, 320)];
        [[self view] setCenter:CGPointMake(160, 240)];
        [[self view] setTransform:CGAffineTransformMakeRotation(M_PI / 2)]; 
        
        // Set frame of movieplayer
        [[mp view] setFrame:CGRectMake(0, 0, 480, 320)];
        
        // Add movie player as subview
        [[self view] addSubview:[mp view]];   
        
        // Play the movie
        [mp play];
    }
}

/*---------------------------------------------------------------------------
 * For 3.1.x devices
 * For 3.2 and 4.x see moviePlayerLoadStateChanged: 
 *--------------------------------------------------------------------------*/
- (void) moviePreloadDidFinish:(NSNotification*)notification 
{
	// Remove observer
	[[NSNotificationCenter 	defaultCenter] removeObserver:self
                                                     name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                   object:nil];
    
	// Play the movie
 	[mp play];
}

/*---------------------------------------------------------------------------
 * 
 *--------------------------------------------------------------------------*/

/*
- (void) moviePlayBackDidFinish:(NSNotification*)notification 
{    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
 	// Remove observer MPMovieFinishReason 
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification 
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(moviePlayBackDidFinishReasonUserInfoKey:) 
                                                 name:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey 
                                               object:nil]; 
    
//	[self dismissModalViewControllerAnimated:YES];	
}
 */

- (void) moviePlayBackDidFinishReasonUserInfoKey:(NSNotification*)notification{    
    int reason = [[[notification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (reason == MPMovieFinishReasonPlaybackEnded) {
        //movie finished playin
    }else if (reason == MPMovieFinishReasonUserExited) {
        //user hit the done button
        [mp pause];
        [mp stop];
        mp = nil;
        [mp release];
        [timer invalidate];
        [self dismissModalViewControllerAnimated:YES];

    }else if (reason == MPMovieFinishReasonPlaybackError) {
        //error
    }
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

}

/*---------------------------------------------------------------------------
 *
 *--------------------------------------------------------------------------*/
- (void) readyPlayer
{
    NSLog(@"movieURL %@",movieURL);
 	mp =  [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    
    if ([mp respondsToSelector:@selector(loadState)]) 
    {
        [mp setShouldAutoplay:YES];
        // Set movie player layout
        [mp setControlStyle:MPMovieControlStyleFullscreen];
        [mp setFullscreen:YES];
        
		// May help to reduce latency
		[mp prepareToPlay];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:20 
                                         target:self
                                       selector:@selector(timerCall:) 
                                       userInfo:nil
                                        repeats:YES];
        
        
		// Register that the load state changed (movie is ready)
		[[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(moviePlayerLoadStateChanged:) 
                                                     name:MPMoviePlayerLoadStateDidChangeNotification 
                                                   object:nil];
	}  
    else
    {
        // Register to receive a notification when the movie is in memory and ready to play.
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(moviePreloadDidFinish:) 
                                                     name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification 
                                                   object:nil];
    }
    
    // Register to receive a notification when the movie has finished playing. 
//    [[NSNotificationCenter defaultCenter] addObserver:self 
//                                             selector:@selector(moviePlayBackDidFinish:) 
//                                                 name:MPMoviePlayerPlaybackDidFinishNotification 
//                                               object:nil]; 
    
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self 
//                                             selector:@selector(moviePlayBackDidFinishReasonUserInfoKey:) 
//                                                 name:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey 
//                                               object:nil]; 
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(moviePlayBackDidFinishReasonUserInfoKey:) 
                                                 name:MPMoviePlayerPlaybackDidFinishNotification 
                                               object:nil];
}

-(void)timerCall:(NSTimer*)time
{
    if (mp) {
        [mp setContentURL:movieURL];
        [mp setInitialPlaybackTime:i];
        [mp play];
        i = i + 20;
    }
}



/*---------------------------------------------------------------------------
 * 
 *--------------------------------------------------------------------------*/
- (void) loadView
{
    [self setView:[[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease]];
	[[self view] setBackgroundColor:[UIColor blackColor]];
}

/*---------------------------------------------------------------------------
 *  
 *--------------------------------------------------------------------------*/
- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification 
                                                  object:nil];
	[mp release];
    [movieURL release];
	[super dealloc];
}

@end
