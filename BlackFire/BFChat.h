//
//  BFChat.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XFChat.h"

@class BFChatWindowController;

typedef enum
{
	BFUserMessageType		= 0,
	BFFriendMessageType		= 1,
	BFWarningMessageType	= 2
} BFIMType;

@interface BFChat : NSObject <XFChatDelegate>
{
	BFChatWindowController *_windowController;
	XFChat *_chat;
	
	NSTextView *_chatHistoryView;
	NSScrollView *_chatScrollView;
}

@property (nonatomic, retain) BFChatWindowController *windowController;
@property (assign) IBOutlet NSTextView *chatHistoryView;
@property (assign) IBOutlet NSScrollView *chatScrollView;
@property (nonatomic, retain) XFChat *chat;

- (id)initWithChat:(XFChat *)chat;

- (void)closeChat;

//------------------------------------------------------------------------------
// Misc methods
- (void)processMessage:(NSString *)msg ofFriend:(NSString *)shortDispName ofType:(BFIMType)type;

@end
