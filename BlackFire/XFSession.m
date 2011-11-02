//
//  XFSession.m
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "XFSession.h"

@implementation XFSession

@synthesize status = _status;

- (void)setStatus:(XFSessionStatus)newStatus
{
	_status = newStatus;
}

@end
