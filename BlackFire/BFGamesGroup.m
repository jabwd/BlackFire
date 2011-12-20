//
//  BFGamesGroup.m
//  BlackFire
//
//  Created by Antwan van Houdt on 6/21/11.
//  Copyright 2011 Exurion. All rights reserved.
//

#import "BFGamesGroup.h"

@implementation BFGamesGroup

@synthesize name;
@synthesize members;

- (id)init
{
    if( (self = [super init]) )
    {
        members = nil;
        name    = nil;
    }
    return self;
}

- (void)dealloc
{
    [name release];
    name = nil;
    [members release];
    members = nil;
    [super dealloc];
}

@end
