//
//  BFLoginViewController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 5/7/2011.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//


#import "BFImageAndTextCell.h"
#import "AHHyperlinkScanner.h"
#import "XFFriend.h"

@implementation BFImageAndTextCell



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
	statusString = nil;
}

- (void)setFriendStatus:(CellStatus)newStatus
{
    if( status == newStatus && _statusImage ) 
        return; // overhead
    
    
	status = newStatus;
	_statusImage = nil;

	switch(newStatus)
	{
		case CellStatusAFK:
			_statusImage = [NSImage imageNamed:@"NSStatusUnavailable"];
			break;
			
		case CellStatusOnline:
			_statusImage = [NSImage imageNamed:@"NSStatusAvailable"];
			break;
			
		case CellStatusOffline:
			_statusImage = [NSImage imageNamed:@"NSStatusNone"];
			break;
            
        default:
            _statusImage = [NSImage imageNamed:@"NSStatusNone"];
            break;
	}
	[_statusImage setScalesWhenResized:true];
	[_statusImage setSize:NSMakeSize(16, 16)];
}

// we draw the image
// let the superview (NSTextFieldCell) draw the image
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
{
	if( cellFrame.size.height > 20 )
	{
		if( ! _image )
			_image = [NSImage imageNamed:@"xfire"];
		if( ! _statusImage )
		{
			_statusImage = [NSImage imageNamed:@"NSStatusAvailable"];
		}
	}
	
	if( groupRow )
	{
		cellFrame.origin.x += 10;
		cellFrame.size.width -= 10;
	}
	/*else if( ! [self isHighlighted] )
	{
		NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.99f alpha:1.0f] endingColor:[NSColor colorWithCalibratedWhite:.95f alpha:1.0f]];
		[gradient drawInRect:NSMakeRect(0, cellFrame.origin.y-1, cellFrame.size.width+8, cellFrame.size.height+2) angle:90.0f];
		[gradient release];
	}*/
	
	/*id objectValue = [self objectValue];
	if( [objectValue isKindOfClass:[XFFriend class]] )
	{
		XFFriend *friend = (XFFriend *)objectValue;
		if( ! _image )
			_image = [friend.avatar retain];
		if( ! _statusImage )
		{
			if( friend.online )
			{
				_statusImage = [[NSImage imageNamed:@"avi_bubble"] retain];
			}
			else {
				_statusImage = [[NSImage imageNamed:@"away_bubble"] retain];
			}
		}
		
		// for the text drawing
		[self setObjectValue:[friend displayName]];
	}*/
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
	[style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
	[style setLineBreakMode:NSLineBreakByTruncatingTail];
	if( _image )
	{
		//cellFrame.origin.x = cellFrame.origin.x - 12.0f;
		cellFrame.size.width += 8.0f; // was 20.0f
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
	
	if( [self isHighlighted] && ([[controlView window] isKeyWindow]) )
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
		}
		[finalStr drawInRect:NSMakeRect(drawPt.x, drawPt.y, cellFrame.size.width-_displayImageSize.width-2.0f, _displayImageSize.height)];
	}
	else
	{
		if( showsStatus )
		{
			drawPt.y -= 6.1f;
			NSMutableAttributedString *finalSt  = [[NSMutableAttributedString alloc] initWithAttributedString:statusString];
			[finalSt addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [finalSt length])];
			[finalSt drawInRect:NSMakeRect(cellFrame.origin.x+6.0f, (9.0f + cellFrame.origin.y + (cellFrame.size.height - bndSize.height)/2.0f), cellFrame.size.width-_displayImageSize.width-4.0f, _displayImageSize.height)];
		}
		NSMutableAttributedString *finalStr = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
		[finalStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [finalStr length])];
		[finalStr drawInRect:NSMakeRect(drawPt.x, drawPt.y, cellFrame.size.width-_displayImageSize.width-4.0f, _displayImageSize.height)];
	}
	[_statusImage compositeToPoint:NSMakePoint(cellFrame.origin.x+cellFrame.size.width-21.0f,cellFrame.origin.y+8.0f+(cellFrame.size.height/2.0f)) operation:NSCompositeSourceOver];
	
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (void)drawWithExpansionFrame:(NSRect)cellFrame inView:(NSView *)view
{
	// no implementation
}

- (NSRect)expansionFrameWithFrame:(NSRect)cellFrame inView:(NSView *)view 
{
	// fix the extra tooltip
    return NSZeroRect;
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
	statusString = [[NSAttributedString alloc] initWithString:aString attributes:attr];
	/*AHHyperlinkScanner *scanner = [[AHHyperlinkScanner alloc] initWithAttributedString:statusString usingStrictChecking:false];
	[statusString release];
	statusString = [[scanner linkifiedString] retain];
	[scanner release];*/
}

- (void)setShowsStatus:(BOOL)aBool{
	if( aBool == NO )
	{
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

