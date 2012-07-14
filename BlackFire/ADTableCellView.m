//
//  ADTableCellView.m
//  BlackFire
//
//  Created by Antwan van Houdt on 6/16/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "ADTableCellView.h"

@implementation ADTableCellView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (void)drawRect:(NSRect)cellFrame
{
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
	[style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
	[style setLineBreakMode:NSLineBreakByTruncatingTail];
	
	if( _image )
	{
		[[NSGraphicsContext currentContext] saveGraphicsState];
		CGFloat yCoordinate = 4.5f;
		NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, yCoordinate, 27, 27) xRadius:3.0f yRadius:3.0f];
		if( cellFrame.size.height == 36 )
			[path setClip];
		[_image setSize:NSMakeSize(27,27)];
		[_image drawAtPoint:NSMakePoint(0, yCoordinate)	fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
		[[NSColor colorWithCalibratedWhite:0.1f alpha:1.0f] set];
		[path stroke];
		[[NSGraphicsContext currentContext] restoreGraphicsState];
	}
	
	NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:_stringValue];
	NSSize stringSize = [text size];
	NSPoint drawPt = NSMakePoint(35,0);
	drawPt.y = 10.0f;
	
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
			[finalSt drawInRect:NSMakeRect(drawPt.x, (drawPt.y)-7, cellFrame.size.width-drawPt.x-6, stringSize.height)];
			drawPt.y += 7.0f;
		}
		
		
		[text drawInRect:NSMakeRect(drawPt.x, drawPt.y, cellFrame.size.width-drawPt.x, stringSize.height)];
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
			[finalSt drawInRect:NSMakeRect(drawPt.x, (drawPt.y)-7, cellFrame.size.width-drawPt.x-6, stringSize.height)];
			drawPt.y += 7.0f;
		}
		
		[text drawInRect:NSMakeRect(drawPt.x, drawPt.y, cellFrame.size.width-drawPt.x, stringSize.height)];
	}
	//[_statusImage compositeToPoint:NSMakePoint(cellFrame.origin.x+cellFrame.size.width-21.0f,cellFrame.origin.y+8.0f+(cellFrame.size.height/2.0f)) operation:NSCompositeSourceOver];
	
	
}

@end
