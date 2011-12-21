//
//  ADModeItem.m
//  TestApp
//
//  Created by Antwan van Houdt on 12/20/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import "ADModeItem.h"

@implementation ADModeItem

@synthesize name		= _name;
@synthesize selected	= _selected;

- (void)dealloc
{
	[_name release];
	_name = nil;
	[super dealloc];
}

- (NSSize)size
{
	NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont systemFontOfSize:[NSFont systemFontSize]],NSFontAttributeName, nil];
	NSAttributedString *str = [[NSAttributedString alloc] initWithString:self.name attributes:attributes];
	[attributes release];
	NSSize size = [str size];
	[str release];
	return size;
}

@end
