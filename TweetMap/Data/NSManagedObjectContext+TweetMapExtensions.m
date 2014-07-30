//
//  NSManagedObjectContext+TweetMapExtensions.m
//  TweetMap
//
//  Created by Oleksii Taran on 7/31/14.
//  Copyright (c) 2014 Oleksii Taran. All rights reserved.
//

#import "NSManagedObjectContext+TweetMapExtensions.h"
#import "OTDefines.h"
#import "OTTweet.h"
#import "OTPerson.h"
#import <MagicalRecord/NSManagedObject+MagicalRecord.h>

//
@implementation NSManagedObjectContext (TweetMapExtensions)

- (BOOL)getTweet:(out OTTweet **)tweet forID:(NSString *)tweetID error:(out NSError **)error
{
	NSParameterAssert(tweet != NULL);
	NSParameterAssert(tweetID != nil);
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [OTTweet MR_entityDescriptionInContext:self];
	request.predicate = [NSPredicate predicateWithFormat:@"%K == %@", OTKey(id), tweetID];
	request.fetchLimit = 1;
	
	NSArray *tweets = [self executeFetchRequest:request error:error];
	if (tweets == nil) {
		return NO;
	}
	
	*tweet = [tweets lastObject];
	return YES;
}

- (BOOL)getPerson:(out OTPerson **)person forID:(NSString *)personID error:(out NSError **)error
{
	NSParameterAssert(person != NULL);
	NSParameterAssert(personID != nil);
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [OTPerson MR_entityDescriptionInContext:self];
	request.predicate = [NSPredicate predicateWithFormat:@"%K == %@", OTKey(id), personID];
	request.fetchLimit = 1;
	
	NSArray *persons = [self executeFetchRequest:request error:error];
	if (persons == nil) {
		return NO;
	}
	
	*person = [persons lastObject];
	return YES;
}

@end
