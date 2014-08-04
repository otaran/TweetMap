//
//  OTTweetViewController.m
//  TweetMap
//
//  Created by Oleksii Taran on 8/4/14.
//  Copyright (c) 2014 Oleksii Taran. All rights reserved.
//

#import "OTTweetViewController.h"
#import "OTTweet.h"
#import "OTPerson.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

//
@interface OTTweetViewController ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *textLabel;

@end

//
@implementation OTTweetViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.dateFormatter = [[NSDateFormatter alloc] init];
	self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
	self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
	
	[self.imageView setImageWithURL:[NSURL URLWithString:self.tweet.user.profileImageURLString]];
	self.authorLabel.text = [@"@" stringByAppendingString:self.tweet.user.screenName];
	self.dateLabel.text = [self.dateFormatter stringFromDate:self.tweet.createdAt];
	self.textLabel.text = self.tweet.text;
}

@end
