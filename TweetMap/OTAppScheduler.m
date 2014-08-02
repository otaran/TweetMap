//
//  OTAppScheduler.m
//  TweetMap
//
//  Created by Oleksii Taran on 8/2/14.
//  Copyright (c) 2014 Oleksii Taran. All rights reserved.
//

#import "OTAppScheduler.h"
#import "OTDataManager.h"

//
@interface OTAppScheduler ()

@property (nonatomic, assign) NSTimeInterval pollingInterval;
@property (nonatomic, strong) NSTimer *pollingTimer;

@end

//
@implementation OTAppScheduler

- (instancetype)initWithDataManager:(OTDataManager *)dataManager locationManager:(CLLocationManager *)locationManager
{
	NSParameterAssert(dataManager != nil);
	NSParameterAssert(locationManager != nil);
	
	self = [super init];
	if (self) {
		_dataManager = dataManager;
		_locationManager = locationManager;
	}
	return self;
}

- (BOOL)startWithPollingInterval:(NSTimeInterval)pollingInterval error:(out NSError **)error
{
	NSParameterAssert(pollingInterval > 0.0);
	NSAssert([NSThread isMainThread], @"Scheduler must be started on main thread");
	
	if (self.running) {
		return YES;
	}
	
	self.running = YES;
	self.pollingInterval = pollingInterval;
	
	self.pollingTimer = [NSTimer timerWithTimeInterval:self.pollingInterval target:self selector:@selector(pollingTimerDidFire:) userInfo:nil repeats:YES];
	self.pollingTimer.tolerance = self.pollingInterval;
	[[NSRunLoop mainRunLoop] addTimer:self.pollingTimer forMode:NSRunLoopCommonModes];
	
	[self pollDataManager];
	
	return YES;
}

- (void)stop
{
	NSAssert([NSThread isMainThread], @"Scheduler must be stopped on main thread");
	
	if (!self.running) {
		return;
	}
	
	self.running = NO;
	
	[self.pollingTimer invalidate];
	self.pollingTimer = nil;
}

#pragma mark -

- (void)pollingTimerDidFire:(NSTimer *)timer
{
	[self pollDataManager];
}

- (void)pollDataManager
{
	CLLocation *location = self.locationManager.location;
	[self.dataManager getLatestTweetsAtLocation:location completionHandler:nil];
}

@end
