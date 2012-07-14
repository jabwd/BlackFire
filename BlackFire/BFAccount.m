//
//  BFAccount.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/5/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFAccount.h"
#import "BFKeychainManager.h"

@implementation BFAccount


- (id)initWithUsername:(NSString *)username
{
	if( (self = [super init]) )
	{
		_username = username;
		_password = [[BFKeychainManager defaultManager] passwordForServiceName:@"BlackFire" accountName:_username];
	}
	return self;
}


#pragma mark - Saving

- (void)save
{
	BFKeychainManager *manager = [BFKeychainManager defaultManager];
	if( [[manager passwordForServiceName:@"BlackFire" accountName:_username] length] > 0 )
	{
		[manager replacePassword:_password serviceName:@"BlackFire" accountName:_username];
	}
	else
	{
		[manager addPassword:_password serviceName:@"BlackFire" accountName:_username];
	}
}

- (void)remove
{
	[[BFKeychainManager defaultManager] removePassword:_password serviceName:@"BlackFire" accountName:_username];
}

@end
