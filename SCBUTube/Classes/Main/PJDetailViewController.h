

#import <UIKit/UIKit.h>

@interface PJDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (retain, nonatomic) id detailItem;

@property (retain, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
