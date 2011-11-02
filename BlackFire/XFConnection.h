//
//  XFConnection.h
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Socket.h"

@class XFSession;

typedef enum
{
	XFConnectionDisconnected = 0,
	XFConnectionStarting,
	XFConnectionConnected,
	XFConnectionStopping
} XFConnectionStatus;

@interface XFConnection : NSObject <SocketDelegate>
{
	XFSession			*_session;
	Socket				*_socket;
	XFConnectionStatus	_status;
}

@property (readonly) XFConnectionStatus status;



//--------------------------------------------------------------
// Connecting

- (void)connect;
- (void)disconnect;
- (void)connectionTimedOut;

@end
