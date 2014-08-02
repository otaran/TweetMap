//
//  OTAppManager.m
//  TweetMap
//
//  Created by Oleksii Taran on 7/30/14.
//  Copyright (c) 2014 Oleksii Taran. All rights reserved.
//

#import "OTAppManager.h"
#import "OTLogging.h"
#import <CocoaLumberjack/DDASLLogger.h>
#import <CocoaLumberjack/DDTTYLogger.h>
#import "OTDataManager.h"
#import "OTAppScheduler.h"

int ddLogLevel =
#ifdef DEBUG
LOG_LEVEL_ALL
#else
LOG_LEVEL_ERROR
#endif
;

//
@interface OTAppManager ()

@property (nonatomic, strong) OTDataManager *dataManager;
@property (nonatomic, strong) CLLocationManager *currentLocationManager;
@property (nonatomic, strong) OTAppScheduler *scheduler;

@end

//
@implementation OTAppManager

+ (instancetype)sharedAppManager
{
	OTAppManager *sharedAppManager = [[UIApplication sharedApplication] delegate];
	return [sharedAppManager isKindOfClass:[OTAppManager class]] ? sharedAppManager : nil;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[DDLog addLogger:[DDASLLogger sharedInstance]];
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	
	self.dataManager = [[OTDataManager alloc] init];
	
	self.currentLocationManager = [[CLLocationManager alloc] init];
	[self.currentLocationManager startUpdatingLocation];
	
	self.scheduler = [[OTAppScheduler alloc] initWithDataManager:self.dataManager locationManager:self.currentLocationManager];
	NSError *schedulerError;
	if (![self.scheduler startWithPollingInterval:5.0 error:&schedulerError]) {
		DDLogError(@"Failed to start scheduler: %@", schedulerError);
	}
	
	return YES;
}

@end
