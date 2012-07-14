//
//  BFMessage.h
//  BlackFire
//
//  Created by Antwan van Houdt on 6/12/11.
//  Copyright 2011 Exurion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFMessage : NSObject

@property (nonatomic, assign) unsigned long timestamp;
@property (nonatomic, assign) unsigned int user;
@property (nonatomic, strong) NSString *message;

- (id)initWithMessage:(NSString *)msg timestamp:(unsigned long)tstamp user:(unsigned int)usr;

@end
