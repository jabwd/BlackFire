//
//  XNResizingMessageView.m
//  TextFieldTest
//
//  Created by Antwan van Houdt on 2/15/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "XNResizingMessageView.h"
#import "BFDefaults.h"

#define ENTRY_TEXTVIEW_PADDING	6
#define BASE_HEIGHT				22
#define MAX_EXTRA_HEIGHT		120
#define MAX_HEIGHT				BASE_HEIGHT+MAX_EXTRA_HEIGHT

#define UPKEY 126
#define DOWNKEY 125
#define ENTER  36
#define ENTER2 76
#define MAX_MESSAGE_HISTORY 5

@interface XNResizingMessageView (Private)

- (void)resetCacheAndPostSizeChanged;
- (void)_init;

@end

@implementation XNResizingMessageView

@synthesize messageDelegate = _messageDelegate;

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
	_maxLength = 4000;
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

- (void)update
{
	[self setNeedsDisplay:true];
}

/*- (void)drawRect:(NSRect)dirtyRect
{
	if( [[self window] firstResponder] == self ) {
		[NSGraphicsContext saveGraphicsState];
        NSSetFocusRingStyle(NSFocusRingOnly);
        NSRectFill(dirtyRect);
		[NSGraphicsContext restoreGraphicsState];
    }
	[super drawRect:dirtyRect];
}*/

#pragma mark - Text input

- (void)textDidChange:(NSNotification *)notification
{
	//Update typing status
	
    //Reset cache and resize
	[[self enclosingScrollView] setNeedsDisplay:true];
	[self resetCacheAndPostSizeChanged]; 
}

- (void)keyDown:(NSEvent *)theEvent
{
    unsigned int keyCode = [theEvent keyCode];
    if( keyCode == ENTER || keyCode == ENTER2 )
    {
        unsigned int modifierFlags = [theEvent modifierFlags];
        if( !(modifierFlags & NSControlKeyMask) && !(modifierFlags & NSAlternateKeyMask) )
        {
            NSString *message = [[[self textStorage] string] copy];
            [_messageDelegate sendMessage:message];
            [self addMessage:message];
            [message release];
            [self setString:@""];
            [self setNeedsDisplay:YES];
			[self resetCacheAndPostSizeChanged];
            return;
        }
        else 
        {
            /*
             * This ensures that the user can type a newline in his
             * message if he wants to
             */
            [super keyDown:theEvent];
            return;
        }
    }
    else if( keyCode == UPKEY )
    {
        if( [[NSUserDefaults standardUserDefaults] boolForKey:BFMessageFieldHistory] )
            [self previousMessage];
		else
			[super keyDown:theEvent];
        return;
    }
    else if( keyCode == DOWNKEY )
    {
        if( [[NSUserDefaults standardUserDefaults] boolForKey:BFMessageFieldHistory] )
            [self nextMessage];
		else
			[super keyDown:theEvent];
        return;
    }
	[_messageDelegate controlTextChanged];
    [super keyDown:theEvent];
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
		//[[NSNotificationCenter defaultCenter] postNotificationName:@"TextViewSizeShouldChange" object:self];
		[_messageDelegate resizeMessageView:self];
	}
}

#pragma mark - Misc

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)becomeKey
{
	[[self window] makeFirstResponder:self];
}


- (void) previousMessage
{
    current++;
    if( current > [previousMessages count] ) // musnt be larger then 5
        current = [previousMessages count];
    
    NSString *message = [previousMessages objectAtIndex:(current-1)];
    if( ! message || current == 0 )
        message = @"";
    
    // load message here
    [self setString:message];
    [self    setNeedsDisplay:YES];
	[self resetCacheAndPostSizeChanged];
}

- (void) nextMessage
{
	if( current > MAX_MESSAGE_HISTORY ) current = MAX_MESSAGE_HISTORY;
	if( current > 0 )
		current--;
	
	NSString *message;
	if( current != 0 )
	{
		// load message here
		message = [previousMessages objectAtIndex:(current-1)];
		if( ! message )
			message = @"";
	}
	else {
		message = @"";
	}
	
    [self setString:message];
	[self    setNeedsDisplay:YES];
	[self resetCacheAndPostSizeChanged];
}

- (void) addMessage:(NSString *)message
{
	current = 0;
	if(! previousMessages )
	{
		previousMessages = [[NSMutableArray alloc] initWithCapacity:MAX_MESSAGE_HISTORY];
	}
	if( [previousMessages count] >= MAX_MESSAGE_HISTORY )
		[previousMessages removeObjectAtIndex:4];
	[previousMessages insertObject:message atIndex:0];
}

@end
