/**
 Copyright (c) 2011, Praveen K Jha, Research2Development Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list
 of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this
 list of conditions and the following disclaimer in the documentation and/or other
 materials provided with the distribution.
 Neither the name of the Research2Development Inc. nor the names of its contributors may be
 used to endorse or promote products derived from this software without specific
 prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 OF THE POSSIBILITY OF SUCH DAMAGE."
 **/

#import <AVFoundation/AVFoundation.h>

@interface DownloadsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate> {
	IBOutlet UINavigationItem *navItem;
	IBOutlet UITableView *table;
	
	NSArray *_DownloadsContents;
	NSString *_DownloadsPath;
	NSMutableArray *_backPaths;
	UITextField *activeField; 
	BOOL keyboardShown; 
	BOOL viewMoved;
    NSArray *listDataArray;
}

@property (retain, readwrite) IBOutlet UITableView *table;
@property (retain, readwrite) NSArray *contents;
@property (retain, readwrite) NSString *path;
@property (retain, readwrite) NSMutableArray *backPaths;
@property (retain, nonatomic) NSArray *listDataArray;

@end