//
//  BFMessage.h
//  BlackFire
//
//  Created by Antwan van Houdt on 6/12/11.
//  Copyright 2011 Exurion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFMessage : NSObject
{
    NSString		*message; 
    unsigned int	timestamp;
    unsigned int	user;
}

@property (nonatomic, assign) unsigned int timestamp;
@property (nonatomic, assign) unsigned int user;
@property (nonatomic, retain) NSString *message;

- (id)initWithMessage:(NSString *)msg timestamp:(unsigned int)tstamp user:(unsigned int)usr;

@end
