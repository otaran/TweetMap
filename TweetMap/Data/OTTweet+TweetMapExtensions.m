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
	CLLocationDegrees const longitude = [[[coordinates objectForKey:@"coordinates"] objectAtIndex:0] doubleValue];
	CLLocationDegrees const latitude  = [[[coordinates objectForKey:@"coordinates"] objectAtIndex:1] doubleValue];
	self.coordinates = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
	return YES;
}

@end
