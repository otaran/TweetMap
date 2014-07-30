//
//  NSManagedObjectContext+TweetMapExtensions.h
//  TweetMap
//
//  Created by Oleksii Taran on 7/31/14.
//  Copyright (c) 2014 Oleksii Taran. All rights reserved.
//

@import CoreData;

//
@class OTTweet;
@class OTPerson;

//
@interface NSManagedObjectContext (TweetMapExtensions)

- (BOOL)getTweet:(out OTTweet **)tweet forID:(NSString *)tweetID error:(out NSError **)error;
- (BOOL)getPerson:(out OTPerson **)person forID:(NSString *)personID error:(out NSError **)error;

@end
