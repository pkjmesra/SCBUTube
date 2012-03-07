/**
 Copyright (c) 2011, Research2Development Inc.
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
/**
 File: CollaborationView.m
 Abstract: Displays the graphics for the view
 Version: 1.0
 **/

#import "CollaborationView.h"

//! Displays the graphics for the view
@implementation CollaborationView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        circle.size = CGSizeMake(kSize,kSize);

        circleHue = 0.0;
        [self newCircle];
    }
    return self;
}

- (void)dealloc {
    [circleColor release];
    [super dealloc];
}

// Creates a circle of a new color to indicate a new round of play.
- (void)newCircle
{
    [circleColor release];
    circleColor = [[UIColor alloc] initWithHue:circleHue 
                                    saturation:0.5 
                                    brightness:1.0 
                                         alpha:1.0];
    circleHue+=0.3;
    if (circleHue > 1.0) circleHue-=1.0;
}

// Called to update the positions of objects that will be drawn on screen.
- (void)updateParty:(CGRect)newCircle
{
    [self setNeedsDisplay];
    circle = newCircle;
}

//// Redraw when there has been an update.
//- (void)drawRect:(CGRect)rect {
//    // Blank the background.
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    //[[UIColor blackColor] set];
//    //UIRectFill(rect);
//    // Draw the circle.
//    [circleColor set];
//    CGContextFillEllipseInRect(context, circle);
//}

@end
