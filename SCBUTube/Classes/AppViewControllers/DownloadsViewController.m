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

#import "DownloadsViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation DownloadsViewController

@synthesize contents = _DownloadsContents;
@synthesize path = _DownloadsPath;
@synthesize backPaths =_backPaths;
@synthesize table;

@synthesize listDataArray;

#pragma mark -
#pragma mark Initialization

- (id)init
{
    self = [super init];
    if (self) {
        _backPaths = [[NSMutableArray alloc] initWithCapacity:0];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        [self setPath:[paths objectAtIndex:0]];
        [self loadContents];
        self.listDataArray = self.contents;
    }
    return self;
}

- (void)loadContents {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *path = self.path;
	NSArray *files = [[fileManager contentsOfDirectoryAtPath:path error:NULL] pathsMatchingExtensions:[NSArray arrayWithObject:@"mp4"]];
	
	if (files) {
		NSMutableArray *filesMutableArray = [NSMutableArray array];
		
		for (NSString *item in files) {
			[filesMutableArray addObject:item];
		}
		
		NSArray *dirs = [[fileManager contentsOfDirectoryAtPath:path error:NULL] pathsMatchingExtensions:[NSArray arrayWithObject:@"containers"]];

		for (NSString *item in dirs) {
			[filesMutableArray addObject:item];
		}
		
//		if ([fileManager fileExistsAtPath:[self.path stringByAppendingPathComponent:@"Archives"]])
//		{
//			[filesMutableArray addObject:@"Archives"];
//		}
		if ([self.path hasSuffix:@"containers"])
		{
			// Add a back button functionality
			[filesMutableArray addObject:@"Back.Back"];
		}
		[self setContents:filesMutableArray];
	}
}

-(NSData *)getImageForCell:(NSString *)fileTitle
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	AVAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@.mp4", [[paths objectAtIndex:0] stringByAppendingPathComponent:fileTitle]]] options:nil];
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

#pragma mark -
#pragma mark View lifecyle

- (void)viewDidLoad {
    
	[super viewDidLoad];
//    self.tableView = self.table;
	_backPaths = [[NSMutableArray alloc] initWithCapacity:0];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	[self setPath:[paths objectAtIndex:0]];
	[self loadContents];
	
    [navItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(back)] autorelease]];
	[navItem setRightBarButtonItem:self.editButtonItem];
	// Additional Code
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasShown:)
												 name:UIKeyboardDidShowNotification
											   object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasHidden:)
												 name:UIKeyboardDidHideNotification
											   object:nil];
	 
}

- (void)back {
	[self dismissModalViewControllerAnimated:YES];
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
	static NSString *CellIdentifier = @"EditCell";
	
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
//	cell.accessoryType = UITableViewCellAccessoryNone;
	
	NSString *selectionName =[self.contents objectAtIndex:[indexPath indexAtPosition:1]];
	BOOL isArchive = [selectionName hasSuffix:@"containers"];
	BOOL isBack = [selectionName hasSuffix:@"Back.Back"];
	
    // Configure the cell...
	if(!isArchive && !isBack)
	{
		NSString *moviePath = [NSString stringWithFormat:@"%@", [self.path stringByAppendingPathComponent:[self.contents objectAtIndex:[indexPath indexAtPosition:1]]]];
		
		AVAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:moviePath] options:nil];
		
		NSString *imagePath = [NSString stringWithFormat:@"%@.png", 
							   [[self.path stringByAppendingPathComponent:
											[self.contents objectAtIndex:[indexPath indexAtPosition:1]]
								  ] stringByDeletingPathExtension]];
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
		{
			// Try finding it in the root dir
			NSString *newimagePath = [NSString stringWithFormat:@"%@.png", 
									  [[[self.path stringByReplacingOccurrencesOfString:[self.path lastPathComponent] withString:@""] stringByAppendingPathComponent:
						   [self.contents objectAtIndex:[indexPath indexAtPosition:1]]
						   ] stringByDeletingPathExtension]];
			if ([[NSFileManager defaultManager] fileExistsAtPath:newimagePath])
			{
				[[NSFileManager defaultManager] moveItemAtPath:newimagePath toPath:imagePath error:nil];
			}
		}
		if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
		{
			// If it still does not exist ? Try creating from asset
			AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
			
			Float64 durationSeconds = CMTimeGetSeconds(asset.duration);
			
			CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds / 20.0, 600);
			CMTime actualTime;
			
			CGImageRef preImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:NULL];
			
			if (preImage != NULL) {
				CGRect rect = CGRectMake(0.0, 0.0,120.0,70.0 );//CGImageGetWidth(preImage) * 0.5, CGImageGetHeight(preImage) * 0.5);
				
				UIImage *image = [UIImage imageWithCGImage:preImage];
				
				UIGraphicsBeginImageContext(rect.size);
				
				[image drawInRect:rect];
				
				NSData *data = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
				
				[[NSFileManager defaultManager] createFileAtPath:imagePath contents:data attributes:nil];
				
				UIGraphicsEndImageContext();
			}
			
			CGImageRelease(preImage);
			[imageGenerator release];
		}
		
		int durationSec = (int)CMTimeGetSeconds(asset.duration);
		int min = durationSec / 60;
		int sec = durationSec % 60;
		
		[asset release];
		[cell.detailTextLabel setText:[NSString stringWithFormat:@"%dm:%02ds", min, sec]];
		if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
		{
			[cell.imageView setImage:[UIImage imageWithContentsOfFile:imagePath]];
		}
		else
		{
			[cell.imageView setImage:[UIImage imageWithData:[self getImageForCell:[self.contents objectAtIndex:[indexPath indexAtPosition:1]]]]];
		}
	}
	else
	{
		[cell.imageView setImage:nil];
		[cell.detailTextLabel setText:nil];
	}

	[cell.textLabel setMinimumFontSize:14.0];
	[cell.textLabel setAdjustsFontSizeToFitWidth:YES];
	[cell.textLabel setText:[[self.contents objectAtIndex:[indexPath indexAtPosition:1]] stringByDeletingPathExtension]];
	UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(60, 20,200, [self tableView:tableView heightForRowAtIndexPath:indexPath])];
	textField.delegate =self;
	textField.adjustsFontSizeToFitWidth = YES;
	textField.textColor = [UIColor blackColor];
	textField.tag = [indexPath indexAtPosition:1];
	textField.placeholder = @"Rename this File or Folder";
	textField.keyboardType = UIKeyboardTypeNamePhonePad;
	textField.returnKeyType = UIReturnKeyDone;
	textField.text = cell.textLabel.text;
	cell.editingAccessoryView = [textField autorelease];
	
	
//	[cell.imageView setBounds:CGRectMake(0, 0, 120.0, 70.0)];
//	[cell.imageView sizeToFit];
    return cell;
}


 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
	 NSString *selectionName =[self.contents objectAtIndex:[indexPath indexAtPosition:1]];
	 BOOL isBack = [selectionName hasSuffix:@"Back.Back"];
	 return !isBack;
 }
 

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		NSString *moviePath = [NSString stringWithFormat:@"%@", [self.path stringByAppendingPathComponent:[self.contents objectAtIndex:[indexPath indexAtPosition:1]]]];
		[fileManager removeItemAtPath:moviePath error:NULL];
		
		NSString *imagePath = [NSString stringWithFormat:@"%@", [self.path stringByAppendingPathComponent:[self.contents objectAtIndex:[indexPath indexAtPosition:1]]]];
		[fileManager removeItemAtPath:imagePath error:NULL];
		
		[self setContents:nil];
		[self loadContents];

		[table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
	/*
	 else if (editingStyle == UITableViewCellEditingStyleInsert) {
	 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
	 }
	 */
}


 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath 
{
	// Move the row from the data source to archive folder
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
//	NSString *archiveDir =[self.path stringByAppendingPathComponent:@"Archives"];
	NSString *fileType =[self.contents objectAtIndex:[toIndexPath indexAtPosition:1]];
	NSString *archiveDir = fileType;
	if ([fileType hasSuffix:@".mp4"])
	{
		archiveDir =[NSString stringWithFormat:@"%@.containers",[self.path stringByAppendingPathComponent:[fileType stringByDeletingPathExtension]]];
		if (![fileManager fileExistsAtPath:archiveDir])
		{
			[fileManager createDirectoryAtPath:archiveDir withIntermediateDirectories:YES attributes:nil error:nil];
		}
		NSString *movietoPath = [NSString stringWithFormat:@"%@", [self.path stringByAppendingPathComponent:[self.contents objectAtIndex:[toIndexPath indexAtPosition:1]]]];
		NSString *movieArchivetoPath =[NSString stringWithFormat:@"%@", [archiveDir stringByAppendingPathComponent:[self.contents objectAtIndex:[toIndexPath indexAtPosition:1]]]];
		
		[fileManager moveItemAtPath:movietoPath toPath:movieArchivetoPath error:NULL];
		
		NSString *imageArchivetoPath =[NSString stringWithFormat:@"%@.png", 
									   [archiveDir stringByAppendingPathComponent:
												[[self.contents objectAtIndex:[toIndexPath indexAtPosition:1]] stringByDeletingPathExtension]]];
		NSString *imagetoPath = [NSString stringWithFormat:@"%@.png", 
								 [self.path stringByAppendingPathComponent:
									[[self.contents objectAtIndex:[toIndexPath indexAtPosition:1]] 
										stringByDeletingPathExtension]]];
		[fileManager moveItemAtPath:imagetoPath toPath:imageArchivetoPath error:NULL];
	}
	else if([fileType hasSuffix:@".containers"])
	{
		archiveDir =[self.path stringByAppendingPathComponent:fileType];
	}
	else if ([fileType hasSuffix:@"Back.Back"])
	{
		// User is trying to move back an item to the parent directory ?
		archiveDir = [self.path stringByReplacingOccurrencesOfString:[self.path lastPathComponent] withString:@""];
		if (![fileManager fileExistsAtPath:archiveDir])
		{
			// Get to the root directory
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			
			archiveDir = [paths objectAtIndex:0];
		}
	}

	NSString *moviePath = [NSString stringWithFormat:@"%@", [self.path stringByAppendingPathComponent:[self.contents objectAtIndex:[fromIndexPath indexAtPosition:1]]]];
	NSString *movieArchivePath =[NSString stringWithFormat:@"%@", [archiveDir stringByAppendingPathComponent:[self.contents objectAtIndex:[fromIndexPath indexAtPosition:1]]]];
	
	NSLog(@"moviePath :%@",moviePath);
	NSLog(@"movieArchivePath :%@",movieArchivePath);
	[fileManager moveItemAtPath:moviePath toPath:movieArchivePath error:NULL];
	
	NSString *imageArchivePath =[NSString stringWithFormat:@"%@.png", [archiveDir stringByAppendingPathComponent:[[self.contents objectAtIndex:[fromIndexPath indexAtPosition:1]] stringByDeletingPathExtension]]];
	NSString *imagePath = [NSString stringWithFormat:@"%@.png", [self.path stringByAppendingPathComponent:[[self.contents objectAtIndex:[fromIndexPath indexAtPosition:1]] stringByDeletingPathExtension]]];
	[fileManager moveItemAtPath:imagePath toPath:imageArchivePath error:NULL];
	
	[self.backPaths addObject:self.path];
	self.path =archiveDir;
	[self setContents:nil];
	[self loadContents];
	[tableView reloadData];
	//[table deleteRowsAtIndexPaths:[NSArray arrayWithObject:fromIndexPath] withRowAnimation:UITableViewRowAnimationFade];
}
 

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
	NSString *selectionName =[self.contents objectAtIndex:[indexPath indexAtPosition:1]];
	BOOL isArchive = [selectionName hasSuffix:@"containers"];
	BOOL isBack = [selectionName hasSuffix:@"Back.Back"];
	if (isArchive || isBack)
		return 40;
	
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if (cell.editing)
    {
        [cell setEditing:YES animated:YES];
        return;
    }
	NSString *selectionName =[self.contents objectAtIndex:[indexPath indexAtPosition:1]];
	if ([selectionName hasSuffix:@".containers"])
	{
		[self.backPaths addObject:self.path];
		self.path =[self.path stringByAppendingPathComponent:selectionName];
		[self loadContents];
		[tableView reloadData];
		return;
	}
	else if ([selectionName hasSuffix:@".Back"])
	{
		self.path = [self.backPaths lastObject];
		[self.backPaths removeObject:self.path];
		[self loadContents];
		[tableView reloadData];
		return;
	}
	[table deselectRowAtIndexPath:indexPath animated:YES];
	NSString *contentURL = [NSString stringWithFormat:@"%@", [self.path stringByAppendingPathComponent:selectionName]];
	
	MPMoviePlayerViewController *moviePlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:contentURL]];
	if (moviePlayerViewController) {
		[self presentMoviePlayerViewControllerAnimated:moviePlayerViewController];
		[moviePlayerViewController.moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
        
        if ([moviePlayerViewController.moviePlayer respondsToSelector:@selector(setAllowsAirPlay:)]) {
            [moviePlayerViewController.moviePlayer setAllowsAirPlay:YES];
        }
		
		[[NSNotificationCenter defaultCenter] addObserverForName:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayerViewController queue:nil usingBlock:^(NSNotification *notification) {
			[[NSNotificationCenter defaultCenter] removeObserver:self];
			[self dismissMoviePlayerViewControllerAnimated];
			[moviePlayerViewController release];
		}];
		
		[moviePlayerViewController.moviePlayer play];
	}
	
//    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
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

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc {
	[self setContents:nil];
	[self setPath:nil];
	
    [super dealloc];
}

#pragma UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:textField.tag inSection:0];
	UITableViewCell *cell = [self tableView:self.table cellForRowAtIndexPath:indexPath];
	[cell.textLabel setText:textField.text];
	
	NSString *selectionName =[self.contents objectAtIndex:[indexPath indexAtPosition:1]];
	
	NSFileManager * fileManager = [NSFileManager defaultManager];
	NSString *oldFile;
	NSString *newFile;

	if ([selectionName hasSuffix:@".containers"])
	{
		oldFile =[NSString stringWithFormat:@"%@.containers",[self.path stringByAppendingPathComponent:[selectionName stringByDeletingPathExtension]]];
		newFile =[NSString stringWithFormat:@"%@.containers",[self.path stringByAppendingPathComponent:textField.text]];
		NSLog(@"oldFile:%@",oldFile);
		NSLog(@"newFile:%@",newFile);
		if (![fileManager fileExistsAtPath:newFile])
		{
			[fileManager moveItemAtPath:oldFile toPath:newFile error:NULL];
		}
	}
	else if ([selectionName hasSuffix:@".mp4"])
	{
		oldFile =[NSString stringWithFormat:@"%@.mp4",[self.path stringByAppendingPathComponent:[selectionName stringByDeletingPathExtension]]];
		newFile =[NSString stringWithFormat:@"%@.mp4",[self.path stringByAppendingPathComponent:textField.text]];
		if (![fileManager fileExistsAtPath:newFile])
		{
			[fileManager moveItemAtPath:oldFile toPath:newFile error:NULL];
		}
		
		oldFile =[NSString stringWithFormat:@"%@.png",[self.path stringByAppendingPathComponent:[selectionName stringByDeletingPathExtension]]];
		newFile =[NSString stringWithFormat:@"%@.png",[self.path stringByAppendingPathComponent:textField.text]];
		if (![fileManager fileExistsAtPath:newFile])
		{
			[fileManager moveItemAtPath:oldFile toPath:newFile error:NULL];
		}
	}
	
	[textField resignFirstResponder];
	
	[self setContents:nil];
	[self loadContents];
	[self.table reloadData];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    activeField = nil;
    // Additional Code
}

- (void)keyboardWasShown:(NSNotification *)aNotification {
	 if ( keyboardShown )
		 return;
	if ([activeField tag]  <2) return; // Do not hide the already showing top 2 text fields by moving the view up

	 {
		 NSDictionary *info = [aNotification userInfo];
		 NSValue *aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
		 CGSize keyboardSize = [aValue CGRectValue].size;
		 
		 NSTimeInterval animationDuration =[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
		 CGRect frame = self.view.frame;
		 frame.origin.y -= keyboardSize.height;
		 frame.size.height += keyboardSize.height;
		 [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
		 [UIView setAnimationDuration:animationDuration];
		 self.view.frame = frame;
		 [UIView commitAnimations];
		 
		 viewMoved = YES;
	 }
	 
	 keyboardShown = YES;
 }
 
- (void)keyboardWasHidden:(NSNotification *)aNotification {
	 if ( viewMoved ) {
		 NSDictionary *info = [aNotification userInfo];
		 NSValue *aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
		 CGSize keyboardSize = [aValue CGRectValue].size;
		 
		 NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
		 CGRect frame = self.view.frame;
		 frame.origin.y += keyboardSize.height;
		 frame.size.height -= keyboardSize.height;
		 [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
		 [UIView setAnimationDuration:animationDuration];
		 self.view.frame = frame;
		 [UIView commitAnimations];
		 
		 viewMoved = NO;
	 }
	 
	 keyboardShown = NO;
 }
	 
@end