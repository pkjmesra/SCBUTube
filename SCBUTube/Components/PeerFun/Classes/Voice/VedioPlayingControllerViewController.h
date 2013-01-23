//
//  VedioPlayingControllerViewController.h
//  SCBUTube
//
//  Created by NAG1-DMAC-26709 on 25/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VedioPlayingControllerViewController : UIViewController

@property (nonatomic,retain) IBOutlet UIWebView *playingView;
@property (nonatomic,retain) NSString *vedioURL;

@end
