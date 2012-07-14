//
//  Socket.h
//  JabSocket
//
//  Created by Antwan van Houdt on 5/28/11.
//  Copyright 2011 Exurion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <arpa/inet.h>

typedef enum
{
    SocketErrorInternet     = 0,
    SocketErrorTimeout      = 1,
    SocketErrorDisconnected = 2,
    SocketErrorUnknownError = 3
    
} SocketError;

typedef enum
{
    SocketStatusDisconnected    = 0,
    SocketStatusConnecting      = 1,
    SocketStatusConnected       = 2,
    SocketStatusDisconnecting   = 3
} SocketStatus;

@protocol  SocketDelegate <NSObject>
- (void)receivedData:(NSData *)data;
- (void)didConnect;
//- (void)unableToConnect;
- (void)didDisconnectWithReason:(SocketError)reason;
@end

@interface Socket : NSObject 
{
    id <SocketDelegate> _delegate;
	CFHostRef           _cfHost;
    CFSocketRef         _cfSocket;
    CFRunLoopSourceRef  _runLoopSource;
	
    SocketStatus        _status;
    unsigned short      _port;
}
@property (nonatomic, strong) id <SocketDelegate> delegate;
@property (nonatomic, assign) unsigned short port;

// initializes this class with a delegate
// a delegate must have been set before this class can be 
// used properly
- (id)initWithDelegate:(id<SocketDelegate>)delegate;


#pragma mark - Connection

/*
 * This method resolves the hostname asynchronously using CFHost
 * and then attempts to connect to that host.
 * will call the delegate method unableToConnect on failure
 */
- (void)connectToHost:(NSString *)hostName;

/*
 * This method converts the string to a network useable IP address
 * and attempts to connect to that address
 * will call the delegate method unableToConnect on failure
 */
- (void)connectToAddress:(NSString *)address;

/*
 * This method attempts to connect to the network ready address
 * and will call the delegate method unableToConnect on failure
 */
- (void)connectToAddressInt:(unsigned int)address;


/*
 * This method performs the actual connecting, after the preperations
 * are done, for instance resolving the host etc.
 */
- (void)performConnect:(NSData *)address;


/*
 * This will disconnect the socket and will cancel any other activities by this class
 */
- (void)disconnect;


/*
 * This method will send data over a connected socket, if nothing is connected
 * or the socket is still connecting it won't do much
 */
- (BOOL)sendData:(NSData *)data;

/*
 * Fires up CFHost to resolve the hostname, when done it will connect the socket
 */
// removed
//- (void)startHostnameResolution:(NSString *)hostname;

/*
 * Cancels any active CFHost hostname resolution
 */
- (void)stopHostnameResolution;

/*
 * Sets the status in the CFSocket callback
 */
- (void)didConnect;

@end
