
@class SCBUTubeViewController;
@class HTTPServer;

@interface SCBUTubeAppDelegate : UIResponder <UIApplicationDelegate> {
    SCBUTubeViewController *viewController;
    UIWindow *window;
	HTTPServer *httpServer;
}

@property (nonatomic, retain) IBOutlet SCBUTubeViewController *viewController;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (retain, nonatomic) UINavigationController *navigationController;

@property (retain, nonatomic) UISplitViewController *splitViewController;
@end

