//
//  OTAppManager.h
//  TweetMap
//
//  Created by Oleksii Taran on 7/30/14.
//  Copyright (c) 2014 Oleksii Taran. All rights reserved.
//

@import UIKit;
@import CoreLocation;

//
@class OTDataManager;

//
@interface OTAppManager : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong, readonly) OTDataManager *dataManager;
@property (nonatomic, strong, readonly) CLLocationManager *currentLocationManager;

+ (instancetype)sharedAppManager;

@end

