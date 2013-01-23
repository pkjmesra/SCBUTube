/**
 Copyright (c) 2011, Praveen K Jha, Research2Development Inc.
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

#import "PJMasterYTViewController.h"
#import "SCBUTubeViewController.h"
#import "PJDetailViewController.h"
#import "PeerLobbyController.h"

@implementation PJMasterYTViewController

@synthesize detailViewController = _detailViewController;
@synthesize detailViewController2 = _detailViewController2;
@synthesize serviceList =_serviceList;
@synthesize transperentView;
@synthesize continueButton;
@synthesize helpTextView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		    self.clearsSelectionOnViewWillAppear = NO;
		    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
		}
    }
    return self;
}

- (void)dealloc
{
	[_detailViewController release];
	[_serviceList release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
	}
    [self designUI];
}

- (void)addTransperentView
{
    self.transperentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)];
    [self.transperentView setBackgroundColor:[UIColor blackColor]];
    [self.transperentView setAlpha:0.7];
    [self.transperentView setOpaque:NO];
    [self.view addSubview:self.transperentView];
}

- (void)addHelpTextView
{
    self.helpTextView = [[UITextView alloc] initWithFrame:CGRectMake(10,30,300,360)];
    NSString *string = [[NSString alloc] initWithString:@"This application provides you some great features:\n\n 1.you can watch as well as download songs from YouTube.\n\n 2.You can do video chat with your friends over bluetooth or wi-fi.\n\n 3. You can stream video/audio data from your friend's device to your's or vice versa.\n\n To use this applicaion you have to turn on wifi/bluetooth from setting."];
    [self.helpTextView setText:string];
    [self.helpTextView setFont:[UIFont fontWithName:@"Helvetica" size:18]];
    [self.helpTextView setBackgroundColor:[UIColor clearColor]];
    [self.helpTextView setTextColor:[UIColor whiteColor]];
    [self.helpTextView setEditable:NO];
    [self.view addSubview:self.helpTextView];
    [string release];
}

- (void)addContinueButton
{
    self.continueButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.continueButton setTitle:@"Continue" forState:UIControlStateNormal];
    self.continueButton.frame = CGRectMake(110,370,100,30);
    [self.continueButton addTarget:self action:@selector(onContinue:) forControlEvents:UIControlEventTouchUpInside];
    [self.continueButton setTitle:@"Continue" forState:UIControlStateNormal];
    [self.view addSubview:self.continueButton];
}

- (void)designUI
{
    [self addTransperentView];
    [self addHelpTextView];
    [self addContinueButton];
    [self.tableView setScrollEnabled:NO];
}

- (void)onContinue:(id)sender
{
    [self.transperentView removeFromSuperview];
    [self.helpTextView removeFromSuperview];
    [self.continueButton removeFromSuperview];
    //This would bring the UITableView down a bit
    UIEdgeInsets inset = UIEdgeInsetsMake(30, 0, 0, 0);
    self.tableView.contentInset = inset;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setHidden:YES];
    [super viewWillAppear:animated];
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    else
        return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;//[_serviceList count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }

    [cell setSelectionStyle:UITableViewCellEditingStyleNone];
    
    NSInteger section = indexPath.section;
    switch (section) {
        case 0:
            [cell setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"youtube-m.png"]]];
            break;
        case 1:
            [cell setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"vdo-call-m.png"]]];
            break;
        case 2:
            [cell setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"sharing-m.png"]]];
            break;
        default:
            break;
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
	{
		int section = indexPath.section;
		switch (section)
		{
			case 0:
				if (!self.detailViewController) 
				{
					self.detailViewController = [[[SCBUTubeViewController alloc] initWithNibName:@"MyTubeViewController" bundle:nil] autorelease];//[[[PJDetailViewController alloc] initWithNibName:@"PJDetailViewController_iPhone" bundle:nil] autorelease];
				}
				self.detailViewController.title = NSLocalizedString(@"Watch/Download", @"Watch/Download");
				[self.navigationController pushViewController:self.detailViewController animated:YES];
				break;
				
			case 1: //Video call with Peers
                _detailViewController2 = [[PeerLobbyController alloc] initWithNibName:@"PeerLobbyController" bundle:nil];
				_detailViewController2.title = NSLocalizedString(@"Peer Call", @"Peer Call");
				((PeerLobbyController *)_detailViewController2).browseMode= section == 2;
				[self.navigationController pushViewController:_detailViewController2 animated:YES];
				[_detailViewController2 release];
				break;
			case 2: //Watch what peers are watching
            {
                PacketType packet = PacketTypeNSArray;
				_detailViewController2 = [[PeerLobbyController alloc] initWithNibName:@"PeerLobbyController" bundle:nil];
				_detailViewController2.title = NSLocalizedString(@"Peer List", @"Peer List");
				((PeerLobbyController *)_detailViewController2).browseMode=NO;
                ((PeerLobbyController *)_detailViewController2).packet = packet;
				[self.navigationController pushViewController:_detailViewController2 animated:YES];
				[_detailViewController2 release];
            }
				break;
				
			default:
				break;
		}
    }
}

@end
