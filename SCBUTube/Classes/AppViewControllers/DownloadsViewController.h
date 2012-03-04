

#import <AVFoundation/AVFoundation.h>

@interface DownloadsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate> {
	IBOutlet UINavigationItem *navItem;
	IBOutlet UITableView *table;
	
	NSArray *_DownloadsContents;
	NSString *_DownloadsPath;
	NSMutableArray *_backPaths;
}

@property (retain, readwrite) IBOutlet UITableView *table;
@property (retain, readwrite) NSArray *contents;
@property (retain, readwrite) NSString *path;
@property (retain, readwrite) NSMutableArray *backPaths;

@end