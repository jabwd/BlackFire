//
//  Socket.m
//  JabSocket
//
//  Created by Antwan van Houdt on 5/28/11.
//  Copyright 2011 Exurion. All rights reserved.
//

#import "Socket.h"
#import <arpa/inet.h>


static void socketCallback(CFSocketRef sock, CFSocketCallBackType cbType, CFDataRef address, const void *data, void *info);
static void hostResolveCallback(CFHostRef theHost, CFHostInfoType typeInfo, const CFStreamError *error, void *info);

@implementation Socket


- (id)init
{
    if( (self = [super init]) )
    {
        _delegate       = nil;
        _cfHost         = NULL;
        _cfSocket       = NULL;
        _runLoopSource  = NULL;
        _port           = 0;
        _status         = SocketStatusDisconnected;
    }
    return self;
}

- (id)initWithDelegate:(id<SocketDelegate>)delegate
{
    if( (self = [super init]) )
    {
        _delegate       = delegate;
        _cfHost         = NULL;
        _cfSocket       = NULL;
        _runLoopSource  = NULL;
        _port           = 0;
        _status         = SocketStatusDisconnected;
    }
    return self;
}

- (void)dealloc
{
    [self disconnect];
}





/*
 * This method resolves the hostname asynchronously using CFHost
 * and then attempts to connect to that host.
 * will call the delegate method unableToConnect on failure
 */
- (void)connectToHost:(NSString *)hostName
{
    if( ! hostName ) return;
    
    if( _cfHost )
        CFRelease(_cfHost);
    
    _cfHost = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)hostName);
    CFHostClientContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    CFHostSetClient(_cfHost, hostResolveCallback, &context);
    CFHostScheduleWithRunLoop(_cfHost, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    if( ! CFHostStartInfoResolution(_cfHost, kCFHostAddresses, NULL) )
    {
        NSLog(@"Unable to resolve host: %@",hostName);
    }
}



/*
 * This method converts the string to a network useable IP address
 * and attempts to connect to that address
 * will call the delegate method unableToConnect on failure
 */
- (void)connectToAddress:(NSString *)address
{
    // TBD
	NSLog(@"*** A method was called which is not in use yet, please make sure you are using the most up to date version of the JABSocket class");
}



/*
 * This method attempts to connect to the network ready address
 * and will call the delegate method unableToConnect on failure
 */
- (void)connectToAddressInt:(unsigned int)address
{
    // TBD
	NSLog(@"*** A method was called which is not in use yet, please make sure you are using the most up to date version of the JABSocket class");
}

/*
 * This method performs the actual connecting, after the preperations
 * are done, for instance resolving the host etc.
 */
- (void)performConnect:(NSData *)address
{
    if( ! address || _port == 0 )
    {
        return;
    }
    if( _status == SocketStatusConnected || _status == SocketStatusConnecting )
    {
        NSLog(@"Attempted to connect an already connected socket!");
        return;
    }
	
	DLog(@"[Notice] Performing connect..");
    
    CFSocketSignature siggie;
    CFSocketContext ctx;
    

    struct sockaddr_in *in_addr = (struct sockaddr_in *)[address bytes];
    
    in_addr->sin_port   = htons(_port);
    in_addr->sin_family = AF_INET;
    
    siggie.protocolFamily   = PF_INET;
    siggie.socketType       = SOCK_STREAM;
    siggie.protocol         = IPPROTO_TCP;
    siggie.address          = (__bridge CFDataRef)[NSData dataWithBytes:in_addr length:sizeof(struct sockaddr_in)];
    
    ctx.version         = 0;
    ctx.info            = (__bridge void *)(self);
    ctx.retain          = nil;
    ctx.release         = nil;
    ctx.copyDescription = nil;
    
    if( _cfSocket )
    {
        if( CFSocketIsValid(_cfSocket) )
        {
            CFSocketInvalidate(_cfSocket);
        }
        CFRelease(_cfSocket);
        _cfSocket = NULL;
    }
    
    _status     = SocketStatusConnecting;
    _cfSocket   = CFSocketCreateConnectedToSocketSignature(kCFAllocatorDefault, 
                                                           &siggie,
                                                           (kCFSocketDataCallBack + kCFSocketConnectCallBack),
                                                           socketCallback, 
                                                           &ctx, 
                                                           -1.0f);
    
    if( _runLoopSource == NULL && _cfSocket )
	{
		_runLoopSource = CFSocketCreateRunLoopSource(NULL,_cfSocket,0);
		CFRunLoopAddSource([[NSRunLoop currentRunLoop] getCFRunLoop],_runLoopSource,kCFRunLoopDefaultMode);
	}
	else {
		NSLog(@"*** Unable to create a socket, please check your internet connection");
	}
}

/*
 * This will disconnect the socket and will cancel any other activities by this class
 */
- (void)disconnect
{
    _status = SocketStatusDisconnected;
    if( _cfSocket )
    {
        CFSocketInvalidate(_cfSocket);
        CFRelease(_cfSocket);
    }
    if( _runLoopSource )
    {
        CFRunLoopRemoveSource( [[NSRunLoop currentRunLoop] getCFRunLoop], _runLoopSource, kCFRunLoopDefaultMode );
        CFRelease(_runLoopSource);
        _runLoopSource = NULL;
    }
    [self stopHostnameResolution];
    _cfSocket = NULL;
}


/*
 * This method will send data over a connected socket, if nothing is connected
 * or the socket is still connecting it won't do much
 */
- (BOOL)sendData:(NSData *)data
{
    if( [data length] < 1 )
    {
        NSLog(@"Called sendData but there was no data");
        return NO;
    }
	DLog(@"[Notice] Sending some data of length %lu",[data length]);
    if( _cfSocket && _status == SocketStatusConnected )
    {
        CFSocketError error = CFSocketSendData(_cfSocket, NULL, (__bridge CFDataRef)data, 1.0f);
        if( error == kCFSocketSuccess )
        {
            return YES;
        }
        else if( error == kCFSocketError )
        {
            // close the connection
            NSLog(@"*** Socket error on sending data, should close the connection now");
            [_delegate didDisconnectWithReason:SocketErrorUnknownError];
            return NO;
        }
        return NO;
    }
    else
    {
        NSLog(@"Tried to send data of length %lu over an invalid Socket",(unsigned long)[data length]);
    }
    return NO;
}



/*
 * Called when the CFSocket receives some data, at this point if no delegate is set
 * nothing will be done
 */
- (void)receivedData:(NSData *)data
{
	DLog(@"[Notice] Receiving some data of length %lu",[data length]);
    if( [data length] > 0 && _delegate )
    {
        [_delegate receivedData:data];
    }
	else if( [data length] < 1 )
	{
		NSLog(@"[Error] Received an empty server response, disconnecting..");
		[_delegate didDisconnectWithReason:SocketErrorUnknownError];
	}
    else
    {
		NSLog(@"[Error] Received some data but no delegate exists, should disconnect here.");
        [_delegate didDisconnectWithReason:SocketErrorDisconnected];
    }
}


/*
 * Used in the CFSocket callback to set the status of the socket once connected
 */
- (void)didConnect
{
    _status = SocketStatusConnected;
    [_delegate didConnect];
}



/*
 * Handle anything that comes through our socket here
 */
static void socketCallback(CFSocketRef sock, CFSocketCallBackType cbType, CFDataRef address, const void *data, void *info)
{
	if( cbType == kCFSocketDataCallBack )
	{
        [(__bridge Socket *)info receivedData:(__bridge NSData *)data];
	}
    else if( cbType == kCFSocketConnectCallBack )
    {
		DLog(@"[Notice] Socket did connect");
        [(__bridge Socket *)info didConnect];
    }
	else
	{
		NSLog(@"*** Received an unknown socket notification");
	}
}



/*
 * This method gets called by CFHost when the resolving of the host is done
 */
static void hostResolveCallback(CFHostRef theHost, CFHostInfoType typeInfo, const CFStreamError *error, void *info)
{
    NSArray *resolvedAddresses = (__bridge NSArray *) CFHostGetAddressing(theHost, NULL);
    if( [resolvedAddresses count] > 0 )
    {
        [(__bridge Socket *)info performConnect:resolvedAddresses[0]];
    }
}

/*
 * Cancels any active CFHost hostname resolution
 */
- (void)stopHostnameResolution
{
    if( ! _cfHost )
        return;
    
    CFHostSetClient(_cfHost, NULL, NULL);
    CFHostCancelInfoResolution(_cfHost, kCFHostAddresses);
    CFHostUnscheduleFromRunLoop(_cfHost, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    CFRelease(_cfHost);
    _cfHost = NULL;
}
@end


