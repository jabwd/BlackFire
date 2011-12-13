//
//  BFLoginViewController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 5/7/2011.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//


#import "BFImageAndTextCell.h"

@implementation BFImageAndTextCell

@synthesize statusImage = _statusImage;
@synthesize status;
@synthesize image = _image;


- (id)copyWithZone:(NSZone *)zone
{
    /*
     * Prepare the cell for re-use
     */
	BFImageAndTextCell *c   = (BFImageAndTextCell*)[super copyWithZone:zone];
	c->_image               = nil;
	c->statusString         = nil;
	c->_statusImage         = nil;
    c->wasHighlighted       = NO;
    c->status               = 0;
    
	return c;
}

- (void)dealloc
{
	[statusString release];
	statusString = nil;
	[_statusImage release];
	_statusImage = nil;
	[_image release];
	_image = nil;
	[super dealloc];
}

- (void)setFriendStatus:(CellStatus)newStatus
{
    if( status == newStatus && _statusImage ) 
        return; // overhead
    
    
	status = newStatus;
	[_statusImage release];
	_statusImage = nil;

	switch(newStatus)
	{
		case CellStatusAFK:
			_statusImage = [[NSImage imageNamed:@"away_bubble"] retain];
			break;
			
		case CellStatusOnline:
			_statusImage = [[NSImage imageNamed:@"avi_bubble"] retain];
			break;
			
		case CellStatusOffline:
			_statusImage = [[NSImage imageNamed:@"offline_bubble"] retain];
			break;
            
        default:
            _statusImage = [[NSImage imageNamed:@"offline_bubble"] retain];
            break;
	}
}

// we draw the image
// let the superview (NSTextFieldCell) draw the image
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
{
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
	[style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
	[style setLineBreakMode:NSLineBreakByTruncatingTail];
	if( _image )
	{
		cellFrame.origin.x = cellFrame.origin.x - 12.0f;
		cellFrame.size.width += 20.0f;
		NSRect imageFrame;
		
		NSDivideRect(cellFrame,&imageFrame,&cellFrame, 3.0f+_displayImageSize.width,NSMinXEdge);
		
		if( [self drawsBackground] )
		{
			[[self backgroundColor] set];
			NSRectFill(imageFrame);
		}
		imageFrame.size = _displayImageSize;
		if( [controlView isFlipped] )
			imageFrame.origin.y += (ceil(cellFrame.size.height+imageFrame.size.height)/2.0f);
		else
			imageFrame.origin.y += (ceil(cellFrame.size.height-imageFrame.size.height)/2.0f);
		
		[_image setSize:_displayImageSize];
		
		[_image compositeToPoint:imageFrame.origin operation:NSCompositeSourceOver];
	}
	
	NSAttributedString *attrStr = [self attributedStringValue];
	NSSize bndSize = [attrStr size];
	NSPoint drawPt;
	
	drawPt.x = cellFrame.origin.x + 2.0f;
	drawPt.y = cellFrame.origin.y + (cellFrame.size.height - bndSize.height)/2.0f;
	
	
	[[NSGraphicsContext currentContext] saveGraphicsState];
	[NSBezierPath clipRect:cellFrame];
	
	if( [self isHighlighted] && [[controlView window] isKeyWindow] )
	{
		NSShadow *shadow = [[NSShadow alloc] init];
		[shadow setShadowOffset:NSMakeSize(1.0f, -1.0f)];
		[shadow setShadowColor:[NSColor colorWithCalibratedRed:0.1f green:0.1f blue:0.1f alpha:0.45f]];
		NSMutableAttributedString *finalStr = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
		[finalStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [finalStr length])];
		[finalStr addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, [finalStr length])];
		if( showsStatus )
		{
			drawPt.y -= 6.1f;
			NSMutableAttributedString *finalSt  = [[NSMutableAttributedString alloc] initWithAttributedString:statusString];
			[finalSt addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, [finalSt length])];
			[finalSt addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [finalSt length])];
			[finalSt drawInRect:NSMakeRect(cellFrame.origin.x+6.0f, (9.0f + cellFrame.origin.y + (cellFrame.size.height - bndSize.height)/2.0f), cellFrame.size.width-_displayImageSize.width-2.0f, _displayImageSize.height)];
			[finalSt release];
		}
		[finalStr drawInRect:NSMakeRect(drawPt.x, drawPt.y, cellFrame.size.width-_displayImageSize.width-2.0f, _displayImageSize.height)];
		[shadow release];
		[finalStr release];
	}
	else
	{
		if( showsStatus )
		{
			drawPt.y -= 6.1f;
			NSMutableAttributedString *finalSt  = [[NSMutableAttributedString alloc] initWithAttributedString:statusString];
			[finalSt addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [finalSt length])];
			[finalSt drawInRect:NSMakeRect(cellFrame.origin.x+6.0f, (9.0f + cellFrame.origin.y + (cellFrame.size.height - bndSize.height)/2.0f), cellFrame.size.width-_displayImageSize.width-2.0f, _displayImageSize.height)];
			[finalSt release];
		}
		NSMutableAttributedString *finalStr = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
		[finalStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [finalStr length])];
		[finalStr drawInRect:NSMakeRect(drawPt.x, drawPt.y, cellFrame.size.width-_displayImageSize.width-2.0f, _displayImageSize.height)];
		[finalStr release];
	}
    [_statusImage setScalesWhenResized:YES];
    [_statusImage setSize:NSMakeSize(12.0f, 12.0f)];
	[_statusImage compositeToPoint:NSMakePoint(cellFrame.origin.x+cellFrame.size.width-21.0f,cellFrame.origin.y+6.0f+(cellFrame.size.height/2.0f)) operation:NSCompositeSourceOver];
	
	[[NSGraphicsContext currentContext] restoreGraphicsState];
	[style release];
}

- (void)drawWithExpansionFrame:(NSRect)cellFrame inView:(NSView *)view
{
	// no implementation, hope this fixes the tooltip bug in the friends list
}


- (NSAttributedString *)statusString
{
	return statusString;
}

- (void)setCellStatusString:(NSString *)aString{
  //  if( [aString isEqualToString:[statusString string]] && ![self isHighlighted] ) return; // no need to refresh
    
    BOOL isHiglighted = [self isHighlighted];
    if( [aString isEqualToString:[statusString string]] && isHiglighted == wasHighlighted )
    {
        // overhead
        return;
    }
    wasHighlighted = isHiglighted;
    
	NSColor *aColor = nil;
	if( isHiglighted )
	{
		if( [[[self controlView] window] isKeyWindow] )
			aColor = [NSColor whiteColor];
		else
			aColor = [NSColor blackColor];
	}
	else 
	{
		aColor = [NSColor darkGrayColor];
	}
	
	
	NSFont *boldFont = [[NSFontManager sharedFontManager] convertWeight:YES ofFont:[NSFont fontWithName:@"Helvetica" size:9.5]];
	
	
	NSDictionary *attr = [[NSDictionary alloc] initWithObjectsAndKeys:aColor,NSForegroundColorAttributeName,
						  boldFont,NSFontAttributeName,
						  nil];
	[statusString release];
	statusString = [[NSAttributedString alloc] initWithString:aString attributes:attr];
	[attr release];
}

- (void)setShowsStatus:(BOOL)aBool{
	if( aBool == NO )
	{
		[statusString release];
		statusString = nil;
	}
	showsStatus = aBool;
}

- (BOOL)showsStatus
{
	return showsStatus;
}

- (NSSize)cellSize
{
	NSSize sz = [super cellSize];
	sz.width += (_displayImageSize.width + 20.0f);
	return sz;
}

- (void)setDisplayImageSize:(NSSize)sz
{
	_displayImageSize = sz;
}

- (NSSize)displayImageSize
{
	return _displayImageSize;
}

@end

