//
//  BFTexturedTextFieldCell.m
//  BlackFire
//
//  Created by Mark Douma on 1/21/2010.
//  Copyright 2010 Mark Douma LLC. All rights reserved.
//

#import "BFTexturedTextFieldCell.h"


@implementation BFTexturedTextFieldCell

- (id)init {
	if ( (self = [super initTextCell:@""]) ) {
		
	}
	return self;
}


- (id)initTextCell:(NSString *)value {
	if ( (self = [super initTextCell:value]) ) {
		
	}
	return self;
}


- (id)initImageCell:(NSImage *)value {
	 
	if ( (self = [super initTextCell:@""]) ) {
		
	}
	return self;
}


- (id)initWithCoder:(NSCoder *)coder {
	 
	if ( (self = [super initWithCoder:coder]) ) {
		
	}
	return self;
}


- (void)encodeWithCoder:(NSCoder *)coder {
	 
	[super encodeWithCoder:coder];
}




- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView 
{
	NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[style setLineBreakMode:NSLineBreakByTruncatingTail];
	[style setAlignment:[self alignment]];
	
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
	[shadow setShadowColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:0.43]];
	
	NSColor *textColor = nil;
	
	BOOL isMainWindow = [[controlView window] isMainWindow];
	
	if (isMainWindow) {
		textColor = [self textColor];
		//textColor = [NSColor controlTextColor];
	} else {
		//textColor = [NSColor controlTextColor];
		textColor = [self textColor];
//		textColor = [NSColor disabledControlTextColor];
	}
	
	NSDictionary *attributes = @{NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSize]], NSParagraphStyleAttributeName: style, NSShadowAttributeName: shadow, NSForegroundColorAttributeName: textColor};
	
	NSAttributedString *richText = [[NSAttributedString alloc] initWithString:[self stringValue] attributes:attributes];
	
	NSRect richTextRect;
	
	richTextRect.size = [richText size];
	richTextRect.origin.x = cellFrame.origin.x;
//	richTextRect.origin.x = ceil( (cellFrame.size.width - richTextRect.size.width)/2.0);
	
	richTextRect.origin.y = ceil( (cellFrame.size.height - richTextRect.size.height)/2.0);
	
	[richText drawInRect:richTextRect];
	
}


@end











