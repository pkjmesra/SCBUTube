

#import "DownloadsViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation DownloadsViewController

@synthesize contents = _DownloadsContents;
@synthesize path = _DownloadsPath;

#pragma mark -
#pragma mark Initialization

- (void)loadContents {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *path = self.path;
	NSArray *files = [[fileManager contentsOfDirectoryAtPath:path error:NULL] pathsMatchingExtensions:[NSArray arrayWithObject:@"mp4"]];
	
	if (files) {
		NSMutableArray *filesMutableArray = [NSMutableArray array];
		
		for (NSString *item in files) {
			[filesMutableArray addObject:[item stringByDeletingPathExtension]];
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
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	[self setPath:[paths objectAtIndex:0]];
	[self loadContents];
	
    [navItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(back)] autorelease]];
	[navItem setRightBarButtonItem:self.editButtonItem];
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
	static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	
    // Configure the cell...
	
	NSString *moviePath = [NSString stringWithFormat:@"%@.mp4", [self.path stringByAppendingPathComponent:[self.contents objectAtIndex:[indexPath indexAtPosition:1]]]];
	
	AVAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:moviePath] options:nil];
	
	NSString *imagePath = [NSString stringWithFormat:@"%@.png", [self.path stringByAppendingPathComponent:[self.contents objectAtIndex:[indexPath indexAtPosition:1]]]];
	
	int durationSec = (int)CMTimeGetSeconds(asset.duration);
	int min = durationSec / 60;
	int sec = durationSec % 60;
	
	[asset release];
	
	[cell.textLabel setMinimumFontSize:14.0];
	[cell.textLabel setAdjustsFontSizeToFitWidth:YES];
	[cell.textLabel setText:[self.contents objectAtIndex:[indexPath indexAtPosition:1]]];
	[cell.detailTextLabel setText:[NSString stringWithFormat:@"%dm:%02ds", min, sec]];
	if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
	{
		[cell.imageView setImage:[UIImage imageWithContentsOfFile:imagePath]];
	}
	else
	{
		[cell.imageView setImage:[UIImage imageWithData:[self getImageForCell:[self.contents objectAtIndex:[indexPath indexAtPosition:1]]]]];
	}
//	[cell.imageView setBounds:CGRectMake(0, 0, 120.0, 70.0)];
//	[cell.imageView sizeToFit];
    return cell;
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
        // Delete the row from the data source.
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		NSString *moviePath = [NSString stringWithFormat:@"%@.mp4", [self.path stringByAppendingPathComponent:[self.contents objectAtIndex:[indexPath indexAtPosition:1]]]];
		[fileManager removeItemAtPath:moviePath error:NULL];
		
		NSString *imagePath = [NSString stringWithFormat:@"%@.png", [self.path stringByAppendingPathComponent:[self.contents objectAtIndex:[indexPath indexAtPosition:1]]]];
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
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [table deselectRowAtIndexPath:indexPath animated:YES];
	
	NSString *contentURL = [NSString stringWithFormat:@"%@.mp4", [self.path stringByAppendingPathComponent:[self.contents objectAtIndex:[indexPath indexAtPosition:1]]]];
	
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

@end