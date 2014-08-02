//
//  NSManagedObject+TweetMapExtensions.m
//  TweetMap
//
//  Created by Oleksii Taran on 8/3/14.
//  Copyright (c) 2014 Oleksii Taran. All rights reserved.
//

#import "NSManagedObject+TweetMapExtensions.h"

//
@implementation NSManagedObject (TweetMapExtensions)

+ (NSString *)entityName
{
	return NSStringFromClass(self);
}

@end
