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
/**
 ARCoordinate.h
 PeerFun
 Abstract:  A co-ordinate point in 3-d space
 Version: 1.0
 **/
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * (180.0/M_PI))

@class ARCoordinate;
@protocol ARPersistentItem
//! Gets or sets the co-ordinate point
@property (nonatomic, readonly) ARCoordinate *arCoordinate;

@optional

/**
 Title and subtitle for use by selection UI. This should be used in cases
 where the label has to be shown on the AR screen of a 2-d handset like iPhone.
**/
- (NSString *)title;
- (NSString *)subtitle;

@end

/**
 A protocol contract for a persistent co-ordinate point.
**/
@protocol ARGeoPersistentItem

// Center latitude and longitude of the annotion view.
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@optional

// Title and subtitle for use by selection UI.
- (NSString *)title;
- (NSString *)subtitle;

@end

//! A co-ordinate point in 3-d space
@interface ARCoordinate : NSObject {
	double radialDistance;
	double inclination;
	double azimuth;
	CGPoint touchPoint;
	NSString *title;
	NSString *subtitle;
}

//! Gets or sets the title of the label
@property (nonatomic, retain) NSString *title;
//! Gets or sets the sub-title of the label
@property (nonatomic, copy) NSString *subtitle;
//! Gets or sets the radial distance from the centre point
@property (nonatomic) double radialDistance;
//! Gets or sets the inclination of the device with respect to 0*
@property (nonatomic) double inclination;
//! Gets or sets the azimuth of the device with respect to x- axis
@property (nonatomic) double azimuth;
/**
 Gets or sets the touch point on the device screen based on which the radial
 distance and azimuth will be calculated and stored
**/
@property (nonatomic) CGPoint touchPoint;

//! An XOR hash of all the parameters defining a co-ordinate point in 3-d space
- (NSUInteger)hash;
//! compares if the current instance of point equals the specified |other| point
- (BOOL)isEqual:(id)other;
//! compares if the current instance of co-ordinate equals the specified |otherCoordinate|
- (BOOL)isEqualToCoordinate:(ARCoordinate *)otherCoordinate;

//! Creates an AR co-ordinate with given parameters
+ (ARCoordinate *)coordinateWithRadialDistance:(double)newRadialDistance 
                                   inclination:(double)newInclination 
                                       azimuth:(double)newAzimuth;


@end
