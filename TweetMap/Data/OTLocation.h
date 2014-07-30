//
//  OTLocation.h
//  TweetMap
//
//  Created by Oleksii Taran on 7/31/14.
//  Copyright (c) 2014 Oleksii Taran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OTTweet;

@interface OTLocation : NSManagedObject

@property (nonatomic, retain) NSSet *tweets;
@end

@interface OTLocation (CoreDataGeneratedAccessors)

- (void)addTweetsObject:(OTTweet *)value;
- (void)removeTweetsObject:(OTTweet *)value;
- (void)addTweets:(NSSet *)values;
- (void)removeTweets:(NSSet *)values;

@end
