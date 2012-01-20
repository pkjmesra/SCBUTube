

#import "DownloadQViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "DownloadInfo.h"
#import "UIDownloadBar.h"

@interface DownloadQViewController()

-(NSString *) niceSize:(long long)sizeInBytes;

@end

@implementation DownloadQViewController

@synthesize contents = _DownloadsContents;

#pragma mark -
#pragma mark Initialization

#pragma mark -
#pragma mark View lifecyle

- (void)viewDidLoad {
	[super viewDidLoad];
	
    [navItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(back)] autorelease]];
	[navItem setRightBarButtonItem:self.editButtonItem];
}

- (void)back {
	[self dismissModalViewControllerAnimated:YES];
}

-(void)reloadAllData
{
	if (_DownloadsContents)
	{
		[table reloadData];
	}
}

#pragma mark -
#pragma mark Delegates

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
    [table setEditing:editing animated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	return [self.contents count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	
    // Configure the cell...
	if (self.contents.count >0)
	{
		DownloadInfo *info = (DownloadInfo *)[self.contents objectAtIndex:[indexPath indexAtPosition:1]];
		if (info && info.bar)
		{
			for (UIView *subView in cell.subviews) {
				if ([subView isKindOfClass:[UIImageView class]])
					[subView removeFromSuperview];
			}
			UIImageView *pausePlay =[[UIImageView alloc] initWithFrame:CGRectMake(282, 9.0, 32.0, 32.0)];
			[cell.textLabel setMinimumFontSize:14.0];
			[cell.textLabel setAdjustsFontSizeToFitWidth:YES];
			[cell.textLabel setText:[info FileTitle]];
			if (info.bar && info.bar.expectedBytes >0)
			{
				if (info.bar.operationFailed)
				{
					[cell.detailTextLabel setText:[NSString stringWithFormat:@"%@/Unknown-Failed!",[self niceSize:info.bar.bytesReceived]]];
				}
				else
				{
					[cell.detailTextLabel setText:[NSString stringWithFormat:@"%@/%@",[self niceSize:info.bar.bytesReceived],[self niceSize:info.bar.expectedBytes]]];
					if (info.bar)
						[cell addSubview:info.bar];
				}
			}
			else
			{
				[cell.detailTextLabel setText:[NSString stringWithFormat:@"%@/Unknown",[self niceSize:info.bar.bytesReceived]]];
			}
			if (!info.bar.inProgress)
			{
				[pausePlay setImage:[UIImage imageNamed:@"ReStart.png"]];
			}
			else
			{
				[pausePlay setImage:[UIImage imageNamed:@"pause.png"]];
			}
			[cell addSubview:pausePlay];
			[pausePlay release];
		}
	}
    return cell;
}

-(NSString *) niceSize:(long long)sizeInBytes
{
	NSNumberFormatter *nf = [[[NSNumberFormatter alloc] init] autorelease];
	[nf setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[nf setNumberStyle:NSNumberFormatterDecimalStyle];
	[nf setMinimumFractionDigits:2];
	[nf setMaximumFractionDigits:2];
	
	double GBs = (double)(sizeInBytes) / (double)(1024 * 1024 * 1024);
	double MBs = (double)(sizeInBytes) / (double)(1024 * 1024);
	double KBs = (double)(sizeInBytes) / (double)(1024);
	
	NSString *fileSize =@"";
	if(GBs >= 1.0)
	{
		NSString *temp = [nf stringFromNumber:[NSNumber numberWithDouble:GBs]];
		fileSize = [NSString stringWithFormat:@"%@GB", temp];
	}
	else if(MBs >= 1.0)
	{
		NSString *temp = [nf stringFromNumber:[NSNumber numberWithDouble:MBs]];
		fileSize = [NSString stringWithFormat:@"%@MB", temp];
	}
	else
	{
		NSString *temp = [nf stringFromNumber:[NSNumber numberWithDouble:KBs]];
		fileSize = [NSString stringWithFormat:@"%@KB", temp];
	}

	return fileSize;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

		if (self.contents && self.contents.count >0)
		{
			DownloadInfo *info = [self.contents objectAtIndex:[indexPath indexAtPosition:1]];
			
			if (info) 
			{
				if (info.bar)
				{
					[info dropDownload];
				}
			}
		}
		//[table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
	/*
	 else if (editingStyle == UITableViewCellEditingStyleInsert) {
	 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
	 }
	 */
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [table deselectRowAtIndexPath:indexPath animated:YES];
	
	if (self.contents && self.contents.count >0)
	{
		DownloadInfo *info = [self.contents objectAtIndex:[indexPath indexAtPosition:1]];
		
		if (info) 
		{
			if (info.bar)
			{
				if (info.bar.operationFailed)
				{
					// This had failed earlier. Try again
					info.bar.operationBreaked =NO;
					[info beginDownload];
				}
				else if (info.bar.operationBreaked)
				{
					[info beginDownload];
				}
				else
				{
					[info pauseDownload];
				}
			}
		}
	}
	// Navigation logic may go here. Create and push another view controller.
    /*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload 
{
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc {
//	[self setContents:nil];
	
    [super dealloc];
}

@end