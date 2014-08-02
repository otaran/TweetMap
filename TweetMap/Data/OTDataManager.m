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
#import "OTLogging.h"

#import "OTTweet.h"
#import "OTPerson.h"

//
NSString * const OTDataManagerErrorDomain = @"com.OleksiiTaran.TweetMap.DataManager";

//
@interface OTDataManager ()

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

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

- (NSURL *)applicationDocumentsDirectoryURL
{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
