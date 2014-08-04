//
//  OTTweet.h
//  TweetMap
//
//  Created by Oleksii Taran on 8/3/14.
//  Copyright (c) 2014 Oleksii Taran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OTLocation, OTPerson;

@interface OTTweet : NSManagedObject

@property (nonatomic, retain) id coordinates;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSSet *locations;
@property (nonatomic, retain) OTPerson *user;
@end

@interface OTTweet (CoreDataGeneratedAccessors)

- (void)addLocationsObject:(OTLocation *)value;
- (void)removeLocationsObject:(OTLocation *)value;
- (void)addLocations:(NSSet *)values;
- (void)removeLocations:(NSSet *)values;

@end
