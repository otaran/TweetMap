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
#import "NSManagedObject+TweetMapExtensions.h"
#import "NSManagedObjectContext+TweetMapExtensions.h"
#import "OTDefines.h"
#import "OTLogging.h"
#import "NSUserDefaults+TweetMapExtensions.h"
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

- (NSPredicate *)predicateForTweetsAtLocation:(CLLocation *)location distance:(CLLocationDistance)distance
{
	NSParameterAssert(location != nil);
	NSParameterAssert(distance >= 0.0);
	
	NSPredicate *hasLocationPredicate = [NSPredicate predicateWithFormat:@"coordinates != NULL"];
	
	CLLocationDegrees const latitude  = location.coordinate.latitude;
	CLLocationDegrees const longitude = location.coordinate.longitude;
	double const earthRadius = 6400000.0;
	double const angle = (distance / earthRadius) * (180.0 / M_PI);
	NSPredicate *inRangePredicate = [NSPredicate predicateWithFormat:@"(latitude - %f) * (latitude - %f) + (longitude - %f) * (longitude - %f) <= %f", latitude, latitude, longitude, longitude, angle * angle];
	
	return [NSCompoundPredicate andPredicateWithSubpredicates:@[hasLocationPredicate, inRangePredicate]];
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
	
	OTTweet *tweet;
	NSError *error;
	if (![self getLatestTweet:&tweet context:self.mainManagedObjectContext error:&error]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			completionHandler(nil, error);
		});
		return;
	}
	
	NSUInteger count = [NSUserDefaults standardUserDefaults].displayedTweetsCount;
	
	[self.twitterAPI getStatusesHomeTimelineWithCount:[@(count) stringValue] sinceID:[tweet.id stringValue] maxID:nil trimUser:nil excludeReplies:nil contributorDetails:nil includeEntities:nil successBlock:^(NSArray *statuses) {
		
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
					NSMutableArray *tweets = [NSMutableArray array];
					for (NSManagedObjectID *objectID in tweetIDs) {
						[tweets addObject:[self.mainManagedObjectContext objectWithID:objectID]];
					}
					
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

- (BOOL)getLatestTweet:(out OTTweet **)tweet context:(NSManagedObjectContext *)context error:(out NSError **)error
{
	NSFetchRequest *request = [OTTweet MR_createFetchRequestInContext:context];
	request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:OTKey(id) ascending:NO]];
	request.fetchLimit = 1;
	
	NSArray *tweets = [context executeFetchRequest:request error:error];
	if (tweets == nil) {
		return NO;
	}
	
	*tweet = [tweets lastObject];
	return YES;
}

- (NSURL *)applicationDocumentsDirectoryURL
{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
