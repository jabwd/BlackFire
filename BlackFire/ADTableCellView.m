//
//  ADTableCellView.m
//  BlackFire
//
//  Created by Antwan van Houdt on 6/16/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "ADTableCellView.h"

@implementation ADTableCellView

@synthesize image = _image;
@synthesize stringValue = _stringValue;
@synthesize statusString = _statusString;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
	[_image release];
	_image = nil;
	[_stringValue release];
	_stringValue = nil;
	[_statusString release];
	_statusString = nil;
	[super dealloc];
}

- (void)drawRect:(NSRect)cellFrame
{
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
	[style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
	[style setLineBreakMode:NSLineBreakByTruncatingTail];
	
	if( _image )
	{
		[_image setSize:NSMakeSize(26,27)];
		[_image compositeToPoint:NSMakePoint(0, 1) operation:NSCompositeSourceOver];
	}
	
	NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:_stringValue];
	NSSize stringSize = [text size];
	NSPoint drawPt = NSMakePoint(30,0);
	drawPt.y = (cellFrame.size.height - stringSize.height)/2.0f;
	
	// basic configuration of the text:
	[text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [_stringValue length])];
	
	if( self.backgroundStyle == NSBackgroundStyleDark )
	{
		// nice shadow for the selected row
		NSShadow *shadow = [[NSShadow alloc] init];
		[shadow setShadowOffset:NSMakeSize(1.0f, -1.0f)];
		[shadow setShadowColor:[NSColor colorWithCalibratedRed:0.1f green:0.1f blue:0.1f alpha:0.45f]];
		[text addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, [_stringValue length])];
		
		// we need a white string now as the backgroundstyle is set to dark!
		[text addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, [_stringValue length])];
		
		// draw the status string if its available.
		if( [_statusString length] > 0  )
		{
			NSMutableAttributedString *finalSt  = [[NSMutableAttributedString alloc] initWithString:_statusString];
			[finalSt addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, [finalSt length])];
			[finalSt addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [finalSt length])];
			[finalSt addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica" size:9.0f] range:NSMakeRange(0, [finalSt length])];
			[finalSt addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, [finalSt length])];
			[finalSt drawInRect:NSMakeRect(drawPt.x+6.0f, (drawPt.y)-7, cellFrame.size.width-drawPt.x-6, stringSize.height)];
			[finalSt release];
			drawPt.y += 7.0f;
		}
		
		
		[text drawInRect:NSMakeRect(drawPt.x, drawPt.y, cellFrame.size.width-drawPt.x, stringSize.height)];
		[shadow release];
	}
	else
	{
		
		// draw the status when needed.
		if( [_statusString length] > 0 )
		{
			NSMutableAttributedString *finalSt  = [[NSMutableAttributedString alloc] initWithString:_statusString];
			[finalSt addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [finalSt length])];
			[finalSt addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedWhite:0.4f alpha:1.0f] range:NSMakeRange(0, [finalSt length])];
			[finalSt addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica" size:9.0f] range:NSMakeRange(0, [finalSt length])];
			[finalSt drawInRect:NSMakeRect(drawPt.x+6.0f, (drawPt.y)-7, cellFrame.size.width-drawPt.x-6, stringSize.height)];
			[finalSt release];
			drawPt.y += 7.0f;
		}
		
		[text drawInRect:NSMakeRect(drawPt.x, drawPt.y, cellFrame.size.width-drawPt.x, stringSize.height)];
	}
	//[_statusImage compositeToPoint:NSMakePoint(cellFrame.origin.x+cellFrame.size.width-21.0f,cellFrame.origin.y+8.0f+(cellFrame.size.height/2.0f)) operation:NSCompositeSourceOver];
	
	
	[text release];
	[style release];
}

@end
