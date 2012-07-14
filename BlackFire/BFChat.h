//
//  BFChat.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XFChat.h"

@class BFChatWindowController, BFWebview;

typedef enum
{
	BFUserMessageType		= 0,
	BFFriendMessageType,
	BFWarningMessageType
} BFIMType;

@interface BFChat : NSObject <XFChatDelegate>

@property (nonatomic, strong) BFChatWindowController *windowController;
@property (unsafe_unretained) IBOutlet BFWebview *webView;
@property (nonatomic, strong) XFChat *chat;

@property (readonly) NSUInteger missedMessages;

- (id)initWithChat:(XFChat *)chat;

- (void)closeChat;

//------------------------------------------------------------------------------
// Misc methods

// called from the chatwindow controller whenever this chat is selected
- (void)becameMainChat;


- (void)displayWarning:(NSString *)warningMessage;
- (void)textDidChange:(NSNotification *)notification;
- (void)updateTabIcon;

/*
 * Processes a plain text string to a NSAttributedString according to the given
 * BlackFire Instant Message Type.
 */
- (void)processMessage:(NSString *)msg ofFriend:(NSString *)shortDispName ofType:(BFIMType)type;
- (void)scrollAnimated:(BOOL)animated;
- (BOOL)shouldScroll;

/*
 * Sends a message over the xfire network
 */
- (void)sendMessage:(NSString *)message;

@end
