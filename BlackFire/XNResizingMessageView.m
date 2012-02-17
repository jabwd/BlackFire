//
//  XNResizingMessageView.m
//  TextFieldTest
//
//  Created by Antwan van Houdt on 2/15/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "XNResizingMessageView.h"

#define ENTRY_TEXTVIEW_PADDING	6
#define BASE_HEIGHT				22
#define MAX_EXTRA_HEIGHT		80
#define MAX_HEIGHT				BASE_HEIGHT+MAX_EXTRA_HEIGHT

@interface XNResizingMessageView (Private)

- (void)resetCacheAndPostSizeChanged;
- (void)_init;

@end

@implementation XNResizingMessageView

@synthesize maxLength = _maxLength;

- (void)_init
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(frameDidChange:) 
												 name:NSViewFrameDidChangeNotification 
											   object:self];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(textDidChange:)
												 name:NSTextDidChangeNotification 
											   object:self];
	_maxLength = -1;
	[self setFont:[NSFont fontWithName:@"Helvetica" size:13.0f]];
}

- (id)initWithFrame:(NSRect)frameRect
{
	if( (self = [super initWithFrame:frameRect]) )
	{
		[self _init];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if( (self = [super initWithCoder:aDecoder]) )
	{
		[self _init];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

#pragma mark - Text input

- (void)textDidChange:(NSNotification *)notification
{
	//Update typing status
	
    //Reset cache and resize
	[self resetCacheAndPostSizeChanged]; 
}

- (void)keyDown:(NSEvent *)inEvent
{
	NSString *charactersIgnoringModifiers = [inEvent charactersIgnoringModifiers];
	
	if( [charactersIgnoringModifiers length] ) 
	{
		unichar		inChar	= [charactersIgnoringModifiers characterAtIndex:0];
		NSUInteger	flags	= [inEvent modifierFlags];
		
		if (false && 
				   (flags & NSAlternateKeyMask) && !(flags & NSShiftKeyMask))
		{
			if (inChar == NSUpArrowFunctionKey) 
			{
				//[self historyUp];
			} else if (inChar == NSDownArrowFunctionKey) {
				//[self historyDown];
			} else {
				[super keyDown:inEvent];
			}
			
		}
		else 
		{
			if( _maxLength > 0 && [[self textStorage] length] >= (_maxLength) )
			{
				NSBeep();
				return;
			}
			[super keyDown:inEvent];
		}
	} 
	else 
		[super keyDown:inEvent]; // no actual text input
}


#pragma mark - Auto resizing

- (NSSize)desiredSize
{
    if (_desiredSizeCached.width == 0) {
        float 		textHeight;
        if ([[self textStorage] length] != 0) {
            //If there is text in this view, let the container tell us its height
			
			//Force glyph generation.  We must do this or usedRectForTextContainer might only return a rect for a
			//portion of our text.
            [[self layoutManager] glyphRangeForTextContainer:[self textContainer]];            
			
            textHeight = [[self layoutManager] usedRectForTextContainer:[self textContainer]].size.height;
        } else {
            //Otherwise, we use the current typing attributes to guess what the height of a line should be
			//textHeight = [NSAttributedString stringHeightForAttributes:[self typingAttributes]];
			textHeight = BASE_HEIGHT - ENTRY_TEXTVIEW_PADDING;
        }
		
		/* When we called glyphRangeForTextContainer, we may have triggered re-entry via
		 *		-[self setFrame:] --> -[self frameDidChange:] --> -[self _resetCacheAndPostSizeChanged]
		 * in which case the second entry through the loop (the future relative to our conversation in this comment) got the correct desired size.
		 * In the present, an *old* value is in textHeight.  We don't want to use that. Jumping gigawatts!
		 */
		if (_desiredSizeCached.width == 0) {
			_desiredSizeCached = NSMakeSize([self frame].size.width, textHeight + ENTRY_TEXTVIEW_PADDING);
		}
    }
	
    return _desiredSizeCached;
}

- (void)frameDidChange:(NSNotification *)notification
{
	//resetCacheAndPostSizeChanged can get us right back to here, resulting in an infinite loop if we're not careful
	if( !_resizing ) 
	{
		_resizing = YES;
		[self resetCacheAndPostSizeChanged];
		_resizing = NO;
	}
}

//Reset the desired size cache and post a size changed notification.  Call after the text's dimensions change
- (void)resetCacheAndPostSizeChanged
{
	//Reset the size cache
	_desiredSizeCached = NSMakeSize(0,0);
	
	//Post notification if size changed
	if (!NSEqualSizes([self desiredSize], lastPostedSize)) 
	{
		lastPostedSize = [self desiredSize];
		if( lastPostedSize.height >= MAX_HEIGHT )
			return; // don't go bigger than this!!
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TextViewSizeShouldChange" object:self];
	}
}

#pragma mark - Misc


@end
