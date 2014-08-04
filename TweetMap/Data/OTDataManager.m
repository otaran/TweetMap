//
//  OTDataManager.m
//  TweetMap
//
//  Created by Oleksii Taran on 7/30/14.
//  Copyright (c) 2014 Oleksii Taran. All rights reserved.
//

#import "OTDataManager.h"
#import <STTwitter/STTwitter.h>
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import <NSArray+Functional/NSArray+Functional.h>
#import "NSManagedObjectContext+TweetMapExtensions.h"
#import "OTDefines.h"
#import "OTLogging.h"

#import "OTTweet.h"
#import "OTPerson.h"

//
NSString * const OTDataManagerErrorDomain = @"com.OleksiiTaran.TweetMap.DataManager";

//
@interface OTDataManager ()

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) STTwitterAPI *twitterAPI;

@end

//
@implementation OTDataManager

- (instancetype)init
{
	self = [super init];
	if (self) {
		NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TweetMap" withExtension:@"momd"];
		_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
		
		_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
		
		NSURL *storeURL = [self.applicationDocumentsDirectoryURL URLByAppendingPathComponent:@"TweetMap.sqlite"];
		NSDictionary *options = @{
			NSMigratePersistentStoresAutomaticallyOption: @YES,
			NSInferMappingModelAutomaticallyOption: @YES,
		};
		NSError *error;
		if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
			DDLogError(@"Failed to create persistent store coordinator: %@", error);
			return nil;
		}
		
		_masterManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
		_masterManagedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
		
		_mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
		_mainManagedObjectContext.parentContext = self.masterManagedObjectContext;
	}
	return self;
}

- (NSPredicate *)tweetsPredicateForLocation:(CLLocation *)location
{
	return [NSPredicate predicateWithValue:YES];
}

- (void)getLatestTweetsWithCompletionHandler:(void (^)(NSArray *, NSError *))completionHandler
{
	completionHandler = completionHandler ?: ^(NSArray *ts, NSError *e) {};
	
	if (self.twitterAPI) {
		[self _getLatestTweetsWithCompletionHandler:completionHandler];
	} else {
		self.twitterAPI = [STTwitterAPI twitterAPIOSWithFirstAccount];
		
		[self.twitterAPI verifyCredentialsWithSuccessBlock:^(NSString *username) {
			[self _getLatestTweetsWithCompletionHandler:completionHandler];
		} errorBlock:^(NSError *error) {
			completionHandler(nil, error);
		}];
	}
}

#pragma mark -

- (void)_getLatestTweetsWithCompletionHandler:(void (^)(NSArray *, NSError *))completionHandler
{
	completionHandler = completionHandler ?: ^(NSArray *ts, NSError *e) {};
	
	[self.twitterAPI getStatusesHomeTimelineWithCount:@"10" sinceID:nil maxID:nil trimUser:nil excludeReplies:nil contributorDetails:nil includeEntities:nil successBlock:^(NSArray *statuses) {
		
		NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
		context.parentContext = self.mainManagedObjectContext;
		
		[context performBlock:^{
			NSMutableArray *tweets = [NSMutableArray arrayWithCapacity:statuses.count];
			
			for (NSDictionary *status in statuses) {
				NSError *error;
				OTTweet *tweet = [self importTweetUsingValues:status context:context error:&error];
				if (tweet) {
					[tweets addObject:tweet];
				} else {
					[self.mainManagedObjectContext performBlock:^{
						completionHandler(nil, error);
					}];
					return;
				}
			}
			
			NSError *error;
			if ([context save:&error]) {
				NSArray *tweetIDs = [tweets valueForKey:OTKey(objectID)];
				[self.mainManagedObjectContext performBlock:^{
					NSArray *tweets = [tweetIDs mapUsingBlock:^(NSManagedObjectID *tweetID) {
						return [self.mainManagedObjectContext objectWithID:tweetID];
					}];
					completionHandler(tweets, nil);
					
					[self.mainManagedObjectContext save:NULL];
					[self.masterManagedObjectContext performBlock:^{
						[self.masterManagedObjectContext save:NULL];
					}];
				}];
			} else {
				[self.mainManagedObjectContext performBlock:^{
					completionHandler(nil, error);
				}];
			}
		}];
	} errorBlock:^(NSError *error) {
		completionHandler(nil, error);
	}];
}

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

- (NSURL *)applicationDocumentsDirectoryURL
{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
