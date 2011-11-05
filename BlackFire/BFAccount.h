//
//  BFAccount.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/5/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//



@interface BFAccount : NSObject
{
	NSString *_username;
	NSString *_password;
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;

- (id)initWithUsername:(NSString *)username;

- (void)save;
- (void)remove;

@end
