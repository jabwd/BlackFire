//
//  BFFriendInformationViewController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 6/9/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "BFFriendInformationViewController.h"

@implementation BFFriendInformationViewController

+ (BFFriendInformationViewController *)friendInformationController
{
	BFFriendInformationViewController *controller = [[BFFriendInformationViewController alloc] initWithNibName:@"BFFriendInformation" bundle:nil];
	return [controller autorelease];
}

@end
