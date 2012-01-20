

#import <AVFoundation/AVFoundation.h>

@interface DownloadQViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UINavigationItem *navItem;
	IBOutlet UITableView *table;
	BOOL isReloading;
	NSMutableArray *_DownloadsContents;
	int cellsLoaded;
}

@property (retain, readwrite) NSMutableArray *contents;
@property (assign, readwrite) BOOL isReloading;

-(void)reloadAllData;
-(void)reloadRowsAtIndexPath:(NSInteger)row;

@end