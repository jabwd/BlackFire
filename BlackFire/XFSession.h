//
//  XFSession.h
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

typedef enum{
	XFSessionStatusOffline		= 0,
	XFSessionStatusConnecting	= 1,
	XFSessionStatusOnline		= 2,
	XFSessionStatusDisconnecting = 3
} XFSessionStatus;

@interface XFSession : NSObject
{
	XFSessionStatus _status;
}

@property (setter = setStatus:) XFSessionStatus status;

@end
