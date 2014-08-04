//
//  NSUserDefaults+TweetMapExtensions.m
//  TweetMap
//
//  Created by Oleksii Taran on 8/4/14.
//  Copyright (c) 2014 Oleksii Taran. All rights reserved.
//

#import "NSUserDefaults+TweetMapExtensions.h"

//
@implementation NSUserDefaults (TweetMapExtensions)

- (CLLocationDistance)searchRadius
{
	return [self doubleForKey:@"Search Radius"];
}

- (void)setSearchRadius:(CLLocationDistance)searchRadius
{
	[self setDouble:searchRadius forKey:@"Search Radius"];
}

- (NSUInteger)displayedTweetsCount
{
	return [self integerForKey:@"Displayed Tweets Count"];
}

- (void)setDisplayedTweetsCount:(NSUInteger)displayedTweetsCount
{
	[self setInteger:displayedTweetsCount forKey:@"Displayed Tweets Count"];
}

- (NSTimeInterval)tweetsPollingInterval
{
	return [self doubleForKey:@"Tweets Polling Interval"];
}

- (void)setTweetsPollingInterval:(NSTimeInterval)tweetsPollingInterval
{
	[self setDouble:tweetsPollingInterval forKey:@"Tweets Polling Interval"];
}

@end
