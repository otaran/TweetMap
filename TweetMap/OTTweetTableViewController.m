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
#import "OTPerson.h"
#import "NSManagedObject+TweetMapExtensions.h"
#import "OTDefines.h"
#import "OTLogging.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "OTTweetViewController.h"
#import "NSUserDefaults+TweetMapExtensions.h"

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
	request.predicate = ({
		CLLocation *location = [OTAppManager sharedAppManager].currentLocationManager.location;
		CLLocationDistance distance = [NSUserDefaults standardUserDefaults].searchRadius;
		[self.dataManager predicateForTweetsAtLocation:location distance:distance];
	});
	request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:OTKey(createdAt) ascending:NO]];
	request.fetchLimit = [NSUserDefaults standardUserDefaults].displayedTweetsCount;
	
	NSManagedObjectContext *context = self.dataManager.mainManagedObjectContext;
	
	self.tweetsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
	self.tweetsController.delegate = self;
	
	NSError *error;
	if (![self.tweetsController performFetch:&error]) {
		DDLogError(@"Failed to fetch tweets: %@", error);
	}
	
	[self.refreshControl addTarget:self action:@selector(getLatestTweets:) forControlEvents:UIControlEventValueChanged];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	[super prepareForSegue:segue sender:sender];
	
	if ([segue.identifier isEqualToString:@"Table Tweet"]) {
		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
		if (indexPath) {
			OTTweetViewController *controller = segue.destinationViewController;
			controller.tweet = [self.tweetsController objectAtIndexPath:indexPath];
		}
	}
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id<NSFetchedResultsSectionInfo> sectionInfo = self.tweetsController.sections[section];
	return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	OTTweet *tweet = [self.tweetsController objectAtIndexPath:indexPath];
	NSURL *avatarURL = [NSURL URLWithString:tweet.user.profileImageURLString];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Tweet" forIndexPath:indexPath];
	
	[cell.imageView setImageWithURL:avatarURL placeholderImage:[[FAKFontAwesome userIconWithSize:24.0] imageWithSize:CGSizeMake(24.0, 24.0)]];
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
	[self.dataManager getLatestTweetsWithCompletionHandler:^(NSArray *latestTweets, NSError *error) {
		[self.refreshControl endRefreshing];
	}];
}

@end
