//
//  OTDataManager.m
//  TweetMap
//
//  Created by Oleksii Taran on 7/30/14.
//  Copyright (c) 2014 Oleksii Taran. All rights reserved.
//

#import "OTDataManager.h"
#import <STTwitter/STTwitter.h>
#import <MagicalRecord/NSManagedObject+MagicalRecord.h>
#import <MagicalRecord/NSManagedObject+MagicalDataImport.h>
#import "NSManagedObjectContext+TweetMapExtensions.h"

#import "OTTweet.h"
#import "OTPerson.h"

//
NSString * const OTDataManagerErrorDomain = @"com.OleksiiTaran.TweetMap.DataManager";

//
@implementation OTDataManager

- (void)getLatestTweetsAtLocation:(CLLocation *)location completionHandler:(void (^)(NSArray *, NSError *))completionHandler
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (completionHandler) {
			completionHandler(nil, [NSError errorWithDomain:OTDataManagerErrorDomain code:kOTDataManagerErrorNotImplemented userInfo:@{}]);
		}
	});
}

#pragma mark -

- (OTTweet *)importTweetUsingValues:(NSDictionary *)values context:(NSManagedObjectContext *)context error:(out NSError **)error
{
	OTTweet *tweet;
	if (![context getTweet:&tweet forID:values[@"id"] error:error]) {
		return nil;
	}
	
	if (tweet == nil) {
		tweet = [OTTweet MR_createInContext:context];
	}
	
	[tweet MR_importValuesForKeysWithObject:values];
	
	return tweet;
}

- (OTPerson *)importPersonUsingValues:(NSDictionary *)values context:(NSManagedObjectContext *)context error:(out NSError **)error
{
	OTPerson *person;
	if (![context getPerson:&person forID:values[@"id"] error:error]) {
		return nil;
	}
	
	if (person == nil) {
		person = [OTPerson MR_createInContext:context];
	}
	
	[person MR_importValuesForKeysWithObject:values];
	
	return person;
}

@end
