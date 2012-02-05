

#import <UIKit/UIKit.h>
#import "SCBUTubeAppDelegate.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([SCBUTubeAppDelegate class]));
    [pool release];
    return retVal;
}
