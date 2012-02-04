//
//  XFFriend.h
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//
//  Stores an XFFriend representation

#if TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
#elif TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
typedef UIImage NSImage; // to fix the avatar property, actually not sure whether this works or not..
#endif

@class XFSession, ADBitList;

@interface XFFriend : NSObject
{
	XFSession	*_session;
	ADBitList	*_receivedMessages;
	
	NSString	*_username;
	NSString	*_nickname;
	NSString	*_firstName;
	NSString	*_lastName;
	NSString	*_statusString;
	NSData		*_sessionID;
	
	NSImage		*_avatar;
	
	NSUInteger	_messageIndex;
	NSUInteger	_userID;
	NSUInteger	_gameID;
	NSUInteger	_gameIP;
	NSUInteger	_gamePort;
	NSUInteger	_teamspeakIP;
	NSUInteger	_teamspeakPort;
	NSUInteger	_publicIP;
	NSUInteger	_publicPort;
	NSUInteger	_natType;
	
	
	
	BOOL _online;
	BOOL _friendOfFriend;
	BOOL _clanFriend;
}

@property (nonatomic, assign) XFSession *session;
@property (nonatomic, retain) ADBitList *receivedMessages;

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *nickname;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSData *sessionID;
@property (nonatomic, retain) NSImage *avatar;

@property (nonatomic, assign) NSUInteger messageIndex;
@property (nonatomic, assign) NSUInteger userID;
@property (nonatomic, assign) NSUInteger gameID;
@property (nonatomic, assign) NSUInteger gamePort;
@property (nonatomic, assign) NSUInteger gameIP;
@property (nonatomic, assign) NSUInteger teamspeakIP;
@property (nonatomic, assign) NSUInteger teamspeakPort;

@property (nonatomic, assign, setter = setOnlineStatus:) BOOL online;
@property (nonatomic, assign) BOOL friendOfFriend;
@property (nonatomic, assign) BOOL clanFriend;

- (id)initWithSession:(XFSession *)session;
- (id)initWithUserID:(NSUInteger)userID;

//------------------------------------------------------------------------------------
// Handy methods

- (NSString *)displayName;
- (NSString *)gameIPString;

- (BOOL)isAFK;
- (NSComparisonResult)compare:(XFFriend *)other;
- (NSComparisonResult)statusCompare:(XFFriend *)other;

/*
 * This method will make sure that we have no useful information
 * about the friend, like status string and game IP address. This is the
 * case when the friend goes offline.
 */
- (void)clearInformation;

@end
