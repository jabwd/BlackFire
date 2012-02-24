//
//  XNResizingMessageView.h
//  TextFieldTest
//
//  Created by Antwan van Houdt on 2/15/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol BFChatMessageViewDelegate
- (void)controlTextChanged;
- (void)sendMessage:(NSString *)message;
- (void)resizeMessageView:(id)messageView;
@end

@interface XNResizingMessageView : NSTextView
{
	NSSize	lastPostedSize;
	NSSize	_desiredSizeCached;
	
	id <BFChatMessageViewDelegate> _messageDelegate;
	
	NSMutableArray	*previousMessages;
	NSInteger		_maxLength;
    unsigned int	current;
	
	BOOL			_resizing;
}

@property (assign) id <BFChatMessageViewDelegate> messageDelegate;
@property (assign) NSInteger maxLength;


//------------------------------------------------------------------------------------
// Auto resizing

- (NSSize)desiredSize;

//------------------------------------------------------------------------------------
// Misc

- (void)previousMessage;
- (void)nextMessage;
- (void)addMessage:(NSString *)message;
- (void)becomeKey;

@end
