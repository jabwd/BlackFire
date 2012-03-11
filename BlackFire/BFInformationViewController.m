//
//  BFInformationViewController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 3/2/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "BFInformationViewController.h"

@implementation BFInformationViewController

- (id)init
{
	if( (self = [super init]) )
	{
		[NSBundle loadNibNamed:@"InformationView" owner:self];
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

#pragma mark - View controlling

@end
