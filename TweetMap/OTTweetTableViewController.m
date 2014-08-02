//
//  OTTweetTableViewController.m
//  TweetMap
//
//  Created by Oleksii Taran on 8/3/14.
//  Copyright (c) 2014 Oleksii Taran. All rights reserved.
//

#import "OTTweetTableViewController.h"
#import "OTAppManager.h"
#import "OTDataManager.h"
#import "OTTweet.h"
#import "NSManagedObject+TweetMapExtensions.h"
#import "OTDefines.h"
#import "OTLogging.h"

//
@interface OTTweetTableViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) OTDataManager *dataManager;
@property (nonatomic, strong) NSFetchedResultsController *tweetsController;

@end

//
@implementation OTTweetTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.dataManager = [OTAppManager sharedAppManager].dataManager;
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[OTTweet entityName]];
	request.predicate = [self.dataManager tweetsPredicateForLocation:nil];
	request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:OTKey(createdAt) ascending:NO]];
	
	NSManagedObjectContext *context = self.dataManager.mainManagedObjectContext;
	
	self.tweetsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
	self.tweetsController.delegate = self;
	
	NSError *error;
	if (![self.tweetsController performFetch:&error]) {
		DDLogError(@"Failed to fetch tweets: %@", error);
	}
	
	[self.refreshControl addTarget:self action:@selector(getLatestTweets:) forControlEvents:UIControlEventValueChanged];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id<NSFetchedResultsSectionInfo> sectionInfo = self.tweetsController.sections[section];
	return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	OTTweet *tweet = [self.tweetsController objectAtIndexPath:indexPath];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Tweet" forIndexPath:indexPath];
	cell.textLabel.text = tweet.text;
	
	return cell;
}

#pragma mark - NSFetchedResultsControllerDelegate methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView reloadData];
}

#pragma mark -

- (IBAction)getLatestTweets:(id)sender
{
	[self.dataManager getLatestTweetsAtLocation:nil completionHandler:^(NSArray *latestTweets, NSError *error) {
		[self.refreshControl endRefreshing];
	}];
}

@end
