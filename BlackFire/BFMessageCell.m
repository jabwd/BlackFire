//
//  BFMessageCell.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFMessageCell.h"

@implementation BFMessageCell



/*- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSString *text = (NSString *)[self objectValue];
	NSString *name = _displayName;
	name = @"! JAB.!";
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	//[dateFormatter setDateFormat:NSDateFormatterBehavior10_4];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	
	NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];
	
	if( [text length] > 0 )
	{
		NSAttributedString *nameString = [[NSAttributedString alloc] initWithString:name];
		[nameString drawInRect:NSMakeRect(cellFrame.origin.x, cellFrame.origin.y+4, cellFrame.size.width, 20)];
		
		//NSAttributedString *dateString = [[NSAttributedString alloc] initWithString:timestamp];
		
		
		NSAttributedString *message = [[NSAttributedString alloc] initWithString:text];
		[message drawInRect:NSMakeRect(cellFrame.origin.x, cellFrame.origin.y+16, cellFrame.size.width, cellFrame.size.height-20)];		
	}
}*/

@end
