
@class SCBUTubeViewController;
@class HTTPServer;

@interface SCBUTubeAppDelegate : NSObject <UIApplicationDelegate> {
    SCBUTubeViewController *viewController;
    UIWindow *window;
	HTTPServer *httpServer;
}

@property (nonatomic, retain) IBOutlet SCBUTubeViewController *viewController;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

