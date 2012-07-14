//
//  BFGamesGroup.m
//  BlackFire
//
//  Created by Antwan van Houdt on 6/21/11.
//  Copyright 2011 Exurion. All rights reserved.
//

#import "BFGamesGroup.h"

@implementation BFGamesGroup

- (id)init
{
    if( (self = [super init]) )
    {
        _members = nil;
        _name    = nil;
    }
    return self;
}

- (void)dealloc
{
    _name = nil;
    _members = nil;
}

@end
