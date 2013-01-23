//
//  CustomMoviePlayerViewController.h
//
//  Copyright iOSDeveloperTips.com All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface CustomMoviePlayerViewController : UIViewController 
{
    MPMoviePlayerController     *mp;
    NSURL 						*movieURL;
    float                       i;
    NSTimer *timer;
}

- (id)initWithPath:(NSString *)moviePath;
- (void)readyPlayer;

@end
