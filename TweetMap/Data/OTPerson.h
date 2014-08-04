//
//  OTPerson.h
//  TweetMap
//
//  Created by Oleksii Taran on 8/3/14.
//  Copyright (c) 2014 Oleksii Taran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OTTweet;

@interface OTPerson : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * profileImageURLString;
@property (nonatomic, retain) NSString * screenName;
@property (nonatomic, retain) NSSet *tweets;
@end

@interface OTPerson (CoreDataGeneratedAccessors)

- (void)addTweetsObject:(OTTweet *)value;
- (void)removeTweetsObject:(OTTweet *)value;
- (void)addTweets:(NSSet *)values;
- (void)removeTweets:(NSSet *)values;

@end
