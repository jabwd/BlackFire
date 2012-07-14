//
//  BFMessage.m
//  BlackFire
//
//  Created by Antwan van Houdt on 6/12/11.
//  Copyright 2011 Exurion. All rights reserved.
//

#import "BFMessage.h"

@implementation BFMessage

- (id)initWithMessage:(NSString *)msg timestamp:(unsigned long)tstamp user:(unsigned int)usr
{
    if( (self = [super init]) )
    {
        _message	= msg;
        _timestamp	= tstamp;
        _user		= usr;
        
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[Message type=%u message=\"%@\"]",_user,_message];
}

@end
