
#import <UIKit/UIKit.h>

@class PJDetailViewController;

@interface PJMasterViewController : UITableViewController

@property (retain, nonatomic) PJDetailViewController *detailViewController;
@property (retain, nonatomic) NSMutableArray *serviceList;
@end
