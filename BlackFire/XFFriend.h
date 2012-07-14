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

@property (nonatomic, unsafe_unretained) XFSession *session;
@property (nonatomic, strong) ADBitList *receivedMessages;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSData *sessionID;
@property (nonatomic, strong) NSImage *avatar;

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
