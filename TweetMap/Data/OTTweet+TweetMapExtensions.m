//
//  OTTweet+TweetMapExtensions.m
//  TweetMap
//
//  Created by Oleksii Taran on 8/4/14.
//  Copyright (c) 2014 Oleksii Taran. All rights reserved.
//

#import "OTTweet+TweetMapExtensions.h"
#import <CoreLocation/CoreLocation.h>

//
@implementation OTTweet (TweetMapExtensions)

- (BOOL)importCoordinates:(id)coordinates
{
	self.coordinates = coordinates;
	if (coordinates) {
		self.latitude  = coordinates[@"coordinates"][1];
		self.longitude = coordinates[@"coordinates"][0];
	}
	
	return YES;
}

@end
