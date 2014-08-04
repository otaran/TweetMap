//
//  OTTweet.h
//  TweetMap
//
//  Created by Oleksii Taran on 8/4/14.
//  Copyright (c) 2014 Oleksii Taran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OTPerson;

@interface OTTweet : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) id coordinates;
@property (nonatomic, retain) OTPerson *user;

@end
