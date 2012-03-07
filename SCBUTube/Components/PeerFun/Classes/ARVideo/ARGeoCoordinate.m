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
 ARGeoCoordinate.m
 PeerFun
 Abstract:  A geo location aware co-ordinate point in 3-d space
 Version: 1.0
 **/
#import "ARGeoCoordinate.h"

//! A geo location aware co-ordinate point in 3-d space
@implementation ARGeoCoordinate
//! Gets or sets the geo location of this co-ordinate
@synthesize geoLocation;

//! Calculates and returns the angle between two co-ordinates points in 3-d space
- (float)angleFromCoordinate:(CLLocationCoordinate2D)first 
                toCoordinate:(CLLocationCoordinate2D)second {
	float longitudinalDifference = second.longitude - first.longitude;
	float latitudinalDifference = second.latitude - first.latitude;
	float possibleAzimuth = (M_PI * .5f) - atan(latitudinalDifference / longitudinalDifference);
	if (longitudinalDifference > 0) return possibleAzimuth;
	else if (longitudinalDifference < 0) return possibleAzimuth + M_PI;
	else if (latitudinalDifference < 0) return M_PI;
	
	return 0.0f;
}

/**
 Starts a calibration using a specified |origin| in 3-d space. It may be noted
 that any co-ordinate can be chosen as origin with respect to which the rest
 of the calculations will be done.
 **/
- (void)calibrateUsingOrigin:(CLLocation *)origin {
	
	if (!self.geoLocation) return;
	
	double baseDistance = [origin distanceFromLocation:self.geoLocation];
	
	self.radialDistance = sqrt(pow(origin.altitude - self.geoLocation.altitude, 2) + pow(baseDistance, 2));
		
	float angle = sin(ABS(origin.altitude - self.geoLocation.altitude) / self.radialDistance);
	
	if (origin.altitude > self.geoLocation.altitude) angle = -angle;
	
	self.inclination = angle;
	self.azimuth = [self angleFromCoordinate:origin.coordinate toCoordinate:self.geoLocation.coordinate];
}

//! Returns a geo co-ordinate for a specified location
+ (ARGeoCoordinate *)coordinateWithLocation:(CLLocation *)location {
	ARGeoCoordinate *newCoordinate = [[ARGeoCoordinate alloc] init];
	newCoordinate.geoLocation = location;
	
	//newCoordinate.title = @"";
	
	return [newCoordinate autorelease];
}

//! Returns a geo co-ordinate for a specified location with respect to a specified |origin|
+ (ARGeoCoordinate *)coordinateWithLocation:(CLLocation *)location 
                                 fromOrigin:(CLLocation *)origin {
	ARGeoCoordinate *newCoordinate = [ARGeoCoordinate coordinateWithLocation:location];
	
	[newCoordinate calibrateUsingOrigin:origin];
		
	return newCoordinate;
}

@end
