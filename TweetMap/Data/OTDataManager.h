//
//  OTDataManager.h
//  TweetMap
//
//  Created by Oleksii Taran on 7/30/14.
//  Copyright (c) 2014 Oleksii Taran. All rights reserved.
//

@import CoreData;
@import CoreLocation;

//
extern NSString * const OTDataManagerErrorDomain;

typedef NS_ENUM(NSInteger, OTDataManagerError) {
	kOTDataManagerErrorNotImplemented = 1,
};

//
@interface OTDataManager : NSObject

- (void)getLatestTweetsAtLocation:(CLLocation *)location completionHandler:(void (^)(NSArray *latestTweets, NSError *error))completionHandler;

@end
