

#import <AVFoundation/AVFoundation.h>

@interface DownloadQViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UINavigationItem *navItem;
	IBOutlet UITableView *table;
	
	NSMutableArray *_DownloadsContents;
}

@property (retain, readwrite) NSMutableArray *contents;

-(void)reloadAllData;

@end