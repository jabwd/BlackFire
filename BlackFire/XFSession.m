//
//  XFSession.m
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "XFSession.h"

NSString *XFVersionTooOldReason		= @"Version too old";
NSString *XFInvalidPasswordReason	= @"Wrong username/password";
NSString *XFNetworkErrorReason		= @"No internet connection";

NSString *XFOtherSessionReason				= @"You logged in on another computer";
NSString *XFServerHungUpReason				= @"Xfire server hung up";
NSString *XFServerStoppedRespondingReason	= @"The Connection timed out";
NSString *XFNormalDisconnectReason			= @"Normal disconnect";

NSString *XFFriendDidChangeNotification		= @"XFFriendDidChangeNotification";
NSString *XFFriendChangeAttribute			= @"XFFriendChangeAttribute";

@implementation XFSession

@synthesize status = _status;

- (void)setStatus:(XFSessionStatus)newStatus
{
	_status = newStatus;
}

@end
