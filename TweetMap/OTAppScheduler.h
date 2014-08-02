//
//  OTAppScheduler.h
//  TweetMap
//
//  Created by Oleksii Taran on 8/2/14.
//  Copyright (c) 2014 Oleksii Taran. All rights reserved.
//

@import CoreLocation;

//
@class OTDataManager;

//
@interface OTAppScheduler : NSObject

@property (nonatomic, strong, readonly) OTDataManager *dataManager;
@property (nonatomic, strong, readonly) CLLocationManager *locationManager;
@property (nonatomic, assign, readonly) NSTimeInterval pollingInterval;

- (instancetype)initWithDataManager:(OTDataManager *)dataManager locationManager:(CLLocationManager *)locationManager;

@property (nonatomic, assign, getter = isRunning) BOOL running;
- (BOOL)startWithPollingInterval:(NSTimeInterval)pollingInterval error:(out NSError **)error;
- (void)stop;

@end
