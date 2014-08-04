//
//  NSUserDefaults+TweetMapExtensions.h
//  TweetMap
//
//  Created by Oleksii Taran on 8/4/14.
//  Copyright (c) 2014 Oleksii Taran. All rights reserved.
//

@import CoreLocation;

//
@interface NSUserDefaults (TweetMapExtensions)

@property (nonatomic, assign) CLLocationDistance searchRadius;
@property (nonatomic, assign) NSUInteger displayedTweetsCount;
@property (nonatomic, assign) NSTimeInterval tweetsPollingInterval;

@end
