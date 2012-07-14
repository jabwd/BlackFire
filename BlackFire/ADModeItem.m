//
//  ADModeItem.m
//  TestApp
//
//  Created by Antwan van Houdt on 12/20/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import "ADModeItem.h"

@implementation ADModeItem



- (NSSize)size
{
	NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont systemFontOfSize:[NSFont systemFontSize]],NSFontAttributeName, nil];
	NSAttributedString *str = [[NSAttributedString alloc] initWithString:self.name attributes:attributes];
	NSSize size = [str size];
	return size;
}

@end
