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

@synthesize username = _username;
@synthesize password = _password;

- (id)initWithUsername:(NSString *)username
{
	if( (self = [super init]) )
	{
		_username = [username retain];
		_password = [[[BFKeychainManager defaultManager] passwordForServiceName:@"BlackFire" accountName:_username] retain];
	}
	return self;
}

- (void)dealloc
{
	[_username release];
	_username = nil;
	[_password release];
	_password = nil;
	[super dealloc];
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
