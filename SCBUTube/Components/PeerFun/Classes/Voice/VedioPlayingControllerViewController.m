//
//  VedioPlayingControllerViewController.m
//  SCBUTube
//
//  Created by NAG1-DMAC-26709 on 25/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VedioPlayingControllerViewController.h"

@interface VedioPlayingControllerViewController ()

@end

@implementation VedioPlayingControllerViewController
@synthesize playingView;
@synthesize vedioURL;

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
    
    NSString * newString = [vedioURL stringByReplacingOccurrencesOfString:@" " withString:@"%20" ];
    NSLog(@"new String is:%@",newString);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:newString]];
    NSLog(@"URL is:%@",vedioURL);
    [self.playingView loadRequest:request];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [playingView release];
    [vedioURL release];
    [super dealloc];
}
@end
