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
 ARViewController.h
 PeerFun
 Abstract:  A view controller for geo co-ordinate system
 Version: 1.0
 **/
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ARCoordinate.h"

//! A protocol contract to make view available for specified |coordinate|
@protocol ARViewDelegate
//! Returns a view available for specified |coordinate|
- (UIView *)viewForCoordinate:(ARCoordinate *)coordinate;
@end

//! A view controller for geo co-ordinate system
@interface ARViewController : UIViewController <UIAccelerometerDelegate, CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
	UIAccelerometer *accelerometerManager;
	
	ARCoordinate *centerCoordinate;
	
	UIImagePickerController *cameraController;
	
	NSObject<ARViewDelegate> *delegate;
	NSObject<CLLocationManagerDelegate> *locationDelegate;
	NSObject<UIAccelerometerDelegate> *accelerometerDelegate;
	
	BOOL scaleViewsBasedOnDistance;
	double maximumScaleDistance;
	double minimumScaleFactor;
	
	//defaults to 20hz;
	double updateFrequency;
	
	BOOL rotateViewsBasedOnPerspective;
	double maximumRotationAngle;
	
@private
	BOOL ar_debugMode;
	
	NSTimer *_updateTimer;
	
	UIView *ar_overlayView;
	
	UILabel *ar_debugView;
	
	NSMutableArray *ar_coordinates;
	NSMutableArray *ar_coordinateViews;
	CGPoint lastPoint;
	//UIImageView *drawImage; // WE MAY NOT NEED THIS AT THIS TIME WHEN WE CAN SIMPLY GET THE VIEWS FROM CO-ORDINATE
	BOOL mouseSwiped;	
	int mouseMoved;
}
//! Gets the array of co-ordinates for this view
@property (readonly) NSArray *coordinates;
//! Gets or sets if the application needs to be run in debug mode
@property BOOL debugMode;
//! Gets or sets if the view needs to scale based on distance from centre location
@property BOOL scaleViewsBasedOnDistance;
//! Gets or sets the maximum scale distance
@property double maximumScaleDistance;
//! Gets or sets the minimum scale distance
@property double minimumScaleFactor;
//! Gets or sets the value indicating if the view is rotated based on perspective.
@property BOOL rotateViewsBasedOnPerspective;
//! Gets or sets the maximum rotation angle possible
@property double maximumRotationAngle;
//! Gets or sets the maximum frequence based on which the view needs to be refreshed.
@property double updateFrequency;


//! The following methods are designed to add coordinates to the underlying data model.
- (void)addCoordinate:(ARCoordinate *)coordinate;
- (void)addCoordinate:(ARCoordinate *)coordinate 
             animated:(BOOL)animated;
- (void)addCoordinates:(NSArray *)newCoordinates;


//! The following methods are designed to remove coordinates from the underlying data model.
- (void)removeCoordinate:(ARCoordinate *)coordinate;
- (void)removeCoordinate:(ARCoordinate *)coordinate 
                animated:(BOOL)animated;
- (void)removeCoordinates:(NSArray *)coordinates;

//! Initializes this controller with a location manager
- (id)initWithLocationManager:(CLLocationManager *)manager;
//! Gets the current image being displayed on screen from the view.
+ (UIImage*) getcurrentImage;
//! Statrs listening to the accelerometer and location events
- (void)startListening;
//! Updates the locations on the current view. 
- (void)updateLocations:(NSTimer *)timer;
//! Returns the 2-d point with respect to the UIView for a given 3-d co-ordinate
- (CGPoint)pointInView:(UIView *)realityView 
         forCoordinate:(ARCoordinate *)coordinate;
//! Checks if the current viewport \/ contains the 3-d co-ordinate point
- (BOOL)viewportContainsCoordinate:(ARCoordinate *)coordinate;
//! Adds the given 2-d point from touch on screen to the 3-d co-ordinate space
- (void) addTouchLocation:(CGPoint) pt;
//! Gets or sets the camera controller for this view
@property (nonatomic, retain) UIImagePickerController *cameraController;
//! Gets or sets the delegate which handles the co-ordinate based view changes 
@property (nonatomic, assign) NSObject<ARViewDelegate> *delegate;
//! Gets or sets the location delegate to manage location changes
@property (nonatomic, assign) NSObject<CLLocationManagerDelegate> *locationDelegate;
//! Gets or sets the accelerometer delegate to handle accelerometer events
@property (nonatomic, assign) NSObject<UIAccelerometerDelegate> *accelerometerDelegate;
//! Gets or sets the centre co-ordinate for calibration
@property (retain) ARCoordinate *centerCoordinate;
//! Gets or sets the accelerometer manager instance
@property (nonatomic, retain) UIAccelerometer *accelerometerManager;
//! Gets or sets the location manager instance
@property (nonatomic, retain) CLLocationManager *locationManager;

@end
