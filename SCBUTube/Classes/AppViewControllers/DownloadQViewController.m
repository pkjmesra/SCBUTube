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

#import "DownloadQViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "DownloadInfo.h"
#import "UIDownloadBar.h"

@interface DownloadQViewController()

-(NSString *) niceSize:(long long)sizeInBytes;

@end

@implementation DownloadQViewController

@synthesize contents = _DownloadsContents;
@synthesize isReloading;

#pragma mark -
#pragma mark Initialization

#pragma mark -
#pragma mark View lifecyle

- (void)viewDidLoad {
	[super viewDidLoad];
	
    [navItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(back)] autorelease]];
	[navItem setRightBarButtonItem:self.editButtonItem];
	cellsLoaded=0;
}

- (void)back {
	[self dismissModalViewControllerAnimated:YES];
}

-(void)reloadRowsAtIndexPath:(NSInteger)row
{
	@try {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
		[table beginUpdates];
		[table reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
		[table endUpdates];
	}
	@catch (NSException *exception) {
		// Probably table reloaded
	}
	@finally {
		//ignore
	}

}
-(void)reloadAllData
{
	if (_DownloadsContents )//&& !isReloading)
	{
		cellsLoaded =0;
		isReloading = YES;
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
			info.bar.tag =[indexPath indexAtPosition:1];
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
//	if (cellsLoaded++ ==[self.contents count])
//	{
//		cellsLoaded =0;
//		isReloading =NO;
//	}
    return cell;
}

-(NSData *)getImageForCell:(NSString *)fileTitle
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	AVAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@.paused", [[paths objectAtIndex:0] stringByAppendingPathComponent:fileTitle]]] options:nil];
	NSString *imagePath = [NSString stringWithFormat:@"%@.png", [[paths objectAtIndex:0] stringByAppendingPathComponent:fileTitle]];
	
	AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
	
	Float64 durationSeconds = CMTimeGetSeconds(asset.duration);
	
	CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds / 2.0, 600);
	CMTime actualTime;
	
	CGImageRef preImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:NULL];
	NSData *data =nil;
	if (preImage != NULL) {
		CGRect rect = CGRectMake(0.0, 0.0,120.0,70.0 );//CGImageGetWidth(preImage) * 0.5, CGImageGetHeight(preImage) * 0.5);
		
		UIImage *image = [UIImage imageWithCGImage:preImage];
		
		UIGraphicsBeginImageContext(rect.size);
		
		[image drawInRect:rect];
		
		data = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
		
		[fileManager createFileAtPath:imagePath contents:data attributes:nil];
		
		UIGraphicsEndImageContext();
	}
	
	CGImageRelease(preImage);
	[imageGenerator release];
	[asset release];
	return data;
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