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
 ARAnnotations.m
 PeerFun
 Abstract:  Manages dynamic annotations and their coordinates on views
 Version: 1.0
 **/
#import "ARAnnotations.h"
#import "ARGeoCoordinate.h"
#import "LACircle.h"

//! Manages dynamic annotations and their coordinates on views
@implementation ARAnnotations

#define BOX_WIDTH 320
#define BOX_HEIGHT 480

//! Initializes this class for a specified |parentView|.
- (id)initForView:(UIView *)parentView {    
	// TODO:Refactor this method and reduce unnecessary location additions
    // at startup
    
    //TODO: We no longer need to have the parentView most probably
	
    ARGeoViewController *viewController = [[ARGeoViewController alloc] init];

	viewController.debugMode = YES;
	
	viewController.delegate = self;
	
	viewController.scaleViewsBasedOnDistance = YES;
	viewController.minimumScaleFactor = .5;
	
	viewController.rotateViewsBasedOnPerspective = YES;
	
	// Add some default touch locations to show on the screen
	NSMutableArray *tempLocationArray = [[NSMutableArray alloc] 
										 initWithCapacity:10];
	
	CLLocation *tempLocation;
	ARGeoCoordinate *tempCoordinate;
	
	CLLocationCoordinate2D location;
	location.latitude = 39.550051;
	location.longitude = -105.782067;
	
	tempLocation = [[CLLocation alloc] 
					initWithCoordinate:location 
					altitude:1609.0 
					horizontalAccuracy:1.0 
					verticalAccuracy:1.0 
					timestamp:[NSDate date]];
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	//tempCoordinate.title = @"Touch somewhere bud:)";
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];

	tempLocation = [[CLLocation alloc] 
					initWithLatitude:45.523875 
					longitude:-122.670399];
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	//tempCoordinate.title = @"Touch somewhere bud:)";
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	tempLocation = [[CLLocation alloc] 
					initWithLatitude:47.620973 
					longitude:-122.347276];
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	//tempCoordinate.title = @"Touch somewhere bud:)";
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	tempLocation = [[CLLocation alloc] 
					initWithLatitude:20.593684 
					longitude:78.96288];
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	tempCoordinate.inclination = M_PI/32;
	//tempCoordinate.title = @"Touch/drag somewhere bud:)";
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	tempLocation = [[CLLocation alloc] 
					initWithLatitude:-40.900557 
					longitude:174.885971];
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	tempCoordinate.inclination = M_PI/40;
	//tempCoordinate.title = @"Touch somewhere bud:)";
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	tempLocation = [[CLLocation alloc] 
					initWithLatitude:32.781078 
					longitude:-96.797111];
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	//tempCoordinate.title = @"Touch somewhere bud:)";
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	// Add all locations for viewing on the default view
	[viewController addCoordinates:tempLocationArray];
	[tempLocationArray release];
	
	// Define a new center as the reference point for rest of the calculations
	CLLocation *newCenter = [[CLLocation alloc] 
							 initWithLatitude:37.41711 
							 longitude:-122.02528];
	
	viewController.centerLocation = newCenter;
	[newCenter release];
	
	[viewController startListening];
	
//	[parentView addSubview:viewController.view];
//	[parentView bringSubviewToFront:viewController.view];
    return viewController;
}

//! Gets the UIView for a specified |coordinate|
- (UIView *)viewForCoordinate:(ARCoordinate *)coordinate 
{
	CGRect theFrame = CGRectMake(0, 0, BOX_WIDTH, BOX_HEIGHT);
	UIImageView *tempView= [[UIImageView alloc] 
							initWithFrame:theFrame];
	
	UILabel *titleLabel = [[UILabel alloc] 
						   initWithFrame:CGRectMake(0, 0, BOX_WIDTH, 20.0)];
	titleLabel.backgroundColor = [UIColor 
								  colorWithWhite:.3 
								  alpha:.8];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.text = coordinate.title;
	[titleLabel sizeToFit];
	
	titleLabel.frame = CGRectMake(BOX_WIDTH / 2.0 - titleLabel.frame.size.width / 2.0 - 4.0, 0, titleLabel.frame.size.width + 8.0, titleLabel.frame.size.height + 8.0);
	
	UIImageView *pointView = [[UIImageView alloc] 
							  initWithFrame:CGRectZero];
	pointView.image = [ARViewController getcurrentImage];
	pointView.frame = CGRectMake((int)(BOX_WIDTH / 2.0 - pointView.image.size.width / 2.0), (int)(BOX_HEIGHT / 2.0 - pointView.image.size.height / 2.0), pointView.image.size.width, pointView.image.size.height);

	[tempView addSubview:titleLabel];
	[tempView addSubview:pointView];
	// Add a circle just to highlight the point nearby the touch location
	//[self addCircleAnnotationWithRadius:tempView atCoordinate:coordinate];

	[titleLabel release];
	[pointView release];
	
	return [tempView autorelease];
}


- (void)dealloc {
    [super dealloc];
}

/** 
 Adds a circle object with default radius on given temporary view |tempView| 
 at a specified |coordinate|
 **/
- (void)addCircleAnnotationWithRadius:(UIView*)tempView
                         atCoordinate:(ARCoordinate *)coordinate 
{
	LACircle * circle = [[LACircle alloc] 
						 initWithFrame:CGRectMake(coordinate.touchPoint.x, coordinate.touchPoint.y, 30 * 2.0f, 30 * 2.0f) 
						 withRadius:30];
	[tempView addSubview:circle];
	[circle setNeedsDisplay];
	[circle release];
}



@end
