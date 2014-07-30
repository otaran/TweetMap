//
//  OTAppManager.m
//  TweetMap
//
//  Created by Oleksii Taran on 7/30/14.
//  Copyright (c) 2014 Oleksii Taran. All rights reserved.
//

#import "OTAppManager.h"
#import "OTDataManager.h"

//
@interface OTAppManager ()

@property (nonatomic, strong) OTDataManager *dataManager;

@end

//
@implementation OTAppManager

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.dataManager = [[OTDataManager alloc] init];
	
	return YES;
}

@end
