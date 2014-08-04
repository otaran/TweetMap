//
//  OTTweetMapViewController.m
//  TweetMap
//
//  Created by Oleksii Taran on 8/4/14.
//  Copyright (c) 2014 Oleksii Taran. All rights reserved.
//

#import "OTTweetMapViewController.h"
#import <MapKit/MapKit.h>
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "OTAppManager.h"
#import "OTDataManager.h"
#import "OTTweet.h"
#import "OTPerson.h"
#import "NSManagedObject+TweetMapExtensions.h"
#import "OTDefines.h"
#import "OTLogging.h"
#import "OTTweetViewController.h"
#import "NSUserDefaults+TweetMapExtensions.h"

//
@interface OTTweetMapViewController () <MKMapViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) OTDataManager *dataManager;

@property (nonatomic, strong) NSFetchedResultsController *tweetsController;

@property (nonatomic, strong) NSMutableDictionary *annotationsByTweetID;

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end

//
@implementation OTTweetMapViewController

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
	
	self.tweetsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.dataManager.mainManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
	self.tweetsController.delegate = self;
	
	NSError *error;
	if (![self.tweetsController performFetch:&error]) {
		DDLogError(@"Failed to fetch tweets: %@", error);
	}
	
	self.annotationsByTweetID = [NSMutableDictionary dictionary];
	
	[self updateAnnotations];
	
	CLLocationCoordinate2D const coordinate = [OTAppManager sharedAppManager].currentLocationManager.location.coordinate;
	CLLocationDistance const distance = 2 * [NSUserDefaults standardUserDefaults].searchRadius;
	self.mapView.region = MKCoordinateRegionMakeWithDistance(coordinate, distance, distance);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	[super prepareForSegue:segue sender:sender];
	
	if ([segue.identifier isEqualToString:@"Map Tweet"]) {
		MKAnnotationView *annotationView = sender;
		NSNumber *tweetID = [[self.annotationsByTweetID keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
			return obj == annotationView.annotation;
		}] anyObject];
		if (tweetID) {
			OTTweetViewController *controller = segue.destinationViewController;
			controller.tweet = ^{
				NSUInteger const index = [self.tweetsController.fetchedObjects indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
					return [[obj id] isEqualToNumber:tweetID];
				}];
				if (index != NSNotFound) {
					return self.tweetsController.fetchedObjects[index];
				}
				return (id)nil;
			}();
		}
	}
}

- (void)updateAnnotations
{
	[self.annotationsByTweetID enumerateKeysAndObjectsUsingBlock:^(id key, id annotation, BOOL *stop) {
		[self.mapView removeAnnotation:annotation];
	}];
	
	[self.annotationsByTweetID removeAllObjects];
	
	[self.tweetsController.fetchedObjects enumerateObjectsUsingBlock:^(OTTweet *tweet, NSUInteger idx, BOOL *stop) {
		MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
		annotation.title = tweet.user.screenName;
		annotation.subtitle = tweet.text;
		annotation.coordinate = CLLocationCoordinate2DMake(tweet.latitude.doubleValue, tweet.longitude.doubleValue);
		self.annotationsByTweetID[tweet.id] = annotation;
	}];
	
	[self.annotationsByTweetID enumerateKeysAndObjectsUsingBlock:^(id key, id annotation, BOOL *stop) {
		[self.mapView addAnnotation:annotation];
	}];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[MKUserLocation class]]) {
		return nil;
	}
	
	MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"Tweet"];
	if (annotationView) {
		annotationView.annotation = annotation;
	} else {
		annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Tweet"];
	}
	
	annotationView.image = [[FAKIonIcons locationIconWithSize:32.0] imageWithSize:CGSizeMake(32.0, 32.0)];
	annotationView.centerOffset = CGPointMake(0.0, -16.0);
	annotationView.canShowCallout = YES;
	annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	[self performSegueWithIdentifier:@"Map Tweet" sender:view];
	[mapView deselectAnnotation:view.annotation animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self updateAnnotations];
}

@end
