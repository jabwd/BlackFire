//
//  BFMessage.m
//  BlackFire
//
//  Created by Antwan van Houdt on 6/12/11.
//  Copyright 2011 Exurion. All rights reserved.
//

#import "BFMessage.h"

@implementation BFMessage

@synthesize message;
@synthesize user;
@synthesize timestamp;

- (id)init
{
    if( (self = [super init]) )
    {
        
    }
    return self;
}

- (id)initWithMessage:(NSString *)msg timestamp:(unsigned int)tstamp user:(unsigned int)usr
{
    if( (self = [super init]) )
    {
        message = [msg retain];
        timestamp = tstamp;
        user = usr;
        
    }
    return self;
}

- (void)dealloc
{
    [message release];
    message = nil;
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[Message type=%u message=\"%@\"]",user,message];
}

@end
