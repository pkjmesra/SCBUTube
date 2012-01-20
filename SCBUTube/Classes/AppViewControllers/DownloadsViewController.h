

#import <AVFoundation/AVFoundation.h>

@interface DownloadsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UINavigationItem *navItem;
	IBOutlet UITableView *table;
	
	NSArray *_DownloadsContents;
	NSString *_DownloadsPath;
}

@property (retain, readwrite) NSArray *contents;
@property (retain, readwrite) NSString *path;

@end