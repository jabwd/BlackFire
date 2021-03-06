//
//  BFChat.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFChat.h"
#import "BFChatWindowController.h"
#import "SFTabView.h"
#import "BFNotificationCenter.h"
#import "BFDefaults.h"

#import "BFGamesManager.h"

#import "BFMessage.h"
#import "BFChatLog.h"

#import "XFSession.h"
#import "XFFriend.h"

#import "BFWebview.h"

#import "AHHyperlinkScanner.h"

#define TIMESTAMP_INTERVAL 30

@implementation BFChat
{
	NSDateFormatter *_dateFormatter;
	NSMutableArray	*_messages;
	
	NSColor			*_userColor;
	NSColor			*_friendColor;
	NSFont			*_chatFont;
	NSFont			*_boldChatFont;
	
	NSTimeInterval  _lastTimestamp;
	BOOL			_typing;
	BOOL			_animating;
}

- (id)initWithChat:(XFChat *)chat
{
	if( (self = [super init]) )
	{
		[NSBundle loadNibNamed:@"BFChat" owner:self];
		_chat = chat;
		_missedMessages = 0;
		_dateFormatter = [[NSDateFormatter alloc] init];
		[_dateFormatter setDateStyle:NSDateFormatterNoStyle];
		[_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		_typing			= false;
		_animating		= false;
		
		_userColor		= [NSColor blueColor];
		_friendColor	= [NSColor redColor];
		_chatFont		= [NSFont fontWithName:@"Lucida Grande" size:12.0f];
		_boldChatFont	= [[NSFontManager sharedFontManager] convertWeight:true ofFont:_chatFont];
		_messages		= [[NSMutableArray alloc] init];
	
		
		if( ! chat.remoteFriend )
		{
			NSLog(@"*** No remotefriend object 0x589129");
		}
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendDidChange:) name:XFFriendDidChangeNotification object:chat.remoteFriend];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatNotificationWasClicked:) name:@"chatFriendClicked" object:chat.remoteFriend];
		
		// disable this for now
		if( [[NSUserDefaults standardUserDefaults] boolForKey:BFEnableChatHistory] && false )
		{
			BFChatLog *chatLog = [[BFChatLog alloc] init];
			chatLog.friendUsername = _chat.remoteFriend.username;
			NSArray *messages = [chatLog getLastMessages:2];
			NSUInteger i, cnt = [messages count];
			for(i=cnt;i>0;i--)
			{
				BFMessage *message = messages[(i-1)];
				if( message.user == BFFriendMessageType )
				{
					[_webView newMessage:message.message ofType:true];
				}
				else if( message.user == BFUserMessageType ) {
					[_webView newMessage:message.message ofType:true];
				}
				else {
					[_webView newWarning:message.message timeStamp:@""];
				}
			}
		}
	}
	return self;
}

- (void)dealloc
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_chat setDelegate:nil];
}

- (void)closeChat
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[[BFNotificationCenter defaultNotificationCenter] deleteBadgeCount:_missedMessages];
	_missedMessages = 0;
	
	if( [[NSUserDefaults standardUserDefaults] boolForKey:BFEnableChatlogs] && [_messages count] > 0 )
	{
		BFChatLog *chatLog = [[BFChatLog alloc] init];
		chatLog.friendUsername = _chat.remoteFriend.username;
		chatLog.date = [NSDate date];
		[chatLog addMessages:_messages];
	}
	
	_messages = nil;
	
	SFTabView *tab = [_windowController tabViewForChat:self];
	tab.missedMessages = _missedMessages;
	[tab setNeedsDisplay:true]; // reset the missed messages count
	[_chat setDelegate:nil];
	[_chat closeChat];
	_chat = nil;
}

- (void)becameMainChat
{
	[[BFNotificationCenter defaultNotificationCenter] deleteBadgeCount:_missedMessages];
	_missedMessages = 0;
	SFTabView *tab = [_windowController tabViewForChat:self];
	tab.missedMessages = _missedMessages;
	[tab setNeedsDisplay:true];
}

- (void)chatNotificationWasClicked:(NSNotification *)notification
{
	[_windowController selectChat:self];
	[[NSApplication sharedApplication] activateIgnoringOtherApps:true];
	[_windowController.window makeKeyAndOrderFront:self];
}

#pragma mark - XFChat Delegate

- (void)receivedMessage:(NSString *)message
{
	[self processMessage:message ofFriend:[_chat.remoteFriend displayName] ofType:BFFriendMessageType];

	BFMessage *msg = [[BFMessage alloc] initWithMessage:message timestamp:[[NSDate date] timeIntervalSince1970] user:BFFriendMessageType];
	[_messages addObject:msg];
	
	if( ![self.windowController.window isMainWindow] || (_windowController.currentChat != self && _windowController.currentChat != nil) )
	{
		[[BFNotificationCenter defaultNotificationCenter] playReceivedSound];
		[[BFNotificationCenter defaultNotificationCenter] postNotificationWithTitle:[NSString stringWithFormat:@"Message from %@",[_chat.remoteFriend displayName]] body:message forChatFriend:_chat.remoteFriend];
		[[NSApplication sharedApplication] requestUserAttention:10];
		_missedMessages++;
		[[BFNotificationCenter defaultNotificationCenter] addBadgeCount:1];
		SFTabView *tab = [_windowController tabViewForChat:self];
		tab.missedMessages = _missedMessages;
		[tab setNeedsDisplay:true];
	}
	else if( ![[NSUserDefaults standardUserDefaults] boolForKey:BFReceiveSoundBackgroundOnly] )
	{
		[[BFNotificationCenter defaultNotificationCenter] playReceivedSound];
	}
    
   /* if( [[_chat.remoteFriend username] isEqualToString:@"gkscr34m"] && ([message isEqualToString:@"yu"] || [message isEqualToString:@"uuuu"] || [message isEqualToString:@"uuu"] || [message isEqualToString:@"u"] || [message isEqualToString:@"uu"] || [message isEqualToString:@"uh"] || [message isEqualToString:@"you"]) )
    {
        [self performSelector:@selector(sendMessage:) withObject:@"u" afterDelay:0.3f];
    }*/
}

- (void)sendMessage:(NSString *)message
{
	if( [message length] < 1 || [message length] > 4000 )
		return;
	
	[self processMessage:message ofFriend:[[_chat loginIdentity] displayName] ofType:BFUserMessageType];
	
	[_chat sendMessage:message];

	BFMessage *msg = [[BFMessage alloc] initWithMessage:message timestamp:[[NSDate date] timeIntervalSince1970] user:BFUserMessageType];
	[_messages addObject:msg];
	
	[[BFNotificationCenter defaultNotificationCenter] playSendSound];
}

- (void)messageDidTimeout
{
	[self displayWarning:@"High latency detected, your friend might not see your messages"];
}

- (void)friendStartedTyping
{
	[self updateTabIcon];
}

- (void)friendStoppedTyping
{
	[self updateTabIcon];
}

#pragma mark - Misc methods

- (void)textDidChange:(NSNotification *)notification
{
	if( ! _typing )
	{
		_typing = true;
		[_chat sendTypingNotification];
		[self performSelector:@selector(userTypingDidEnd) withObject:nil afterDelay:3.0f];
	}
}

- (void)userTypingDidEnd
{
	_typing = false;
}

- (void)updateTabIcon
{
	NSImage *displayImage = nil;
	if( _chat.isFriendTyping )
	{
		displayImage = [NSImage imageNamed:@"tab-typing"];
	}
	else if( _chat.remoteFriend.avatar )
	{
		displayImage = _chat.remoteFriend.avatar;
	}
	else 
	{
		displayImage = [NSImage imageNamed:@"xfire"];
	}
	SFTabView *tabView = [_windowController tabViewForChat:self];
	tabView.image = displayImage;
	[tabView setNeedsDisplay:true];
}

- (void)friendDidChange:(NSNotification *)notification
{
	XFFriendNotification notificationType = [[notification userInfo][@"type"] intValue];
	
	[self updateTabIcon];
	
	switch(notificationType)
	{
		case XFFriendNotificationOnlineStatusChanged:
		{
			if( _chat.remoteFriend.online )
			{
				[self displayWarning:[NSString stringWithFormat:@"%@ came online",[_chat.remoteFriend displayName]]];
			}
			else
			{
				[self displayWarning:[NSString stringWithFormat:@"%@ went offline",[_chat.remoteFriend displayName]]];
			}
		}
			break;
			
		case XFFriendNotificationSessionChanged:
		{
			if( _chat.remoteFriend.online )
			{
				[self displayWarning:[NSString stringWithFormat:@"%@ switched to another computer",[_chat.remoteFriend displayName]]];
			}
		}
			break;
			
		case XFFriendNotificationStatusChanged:
		{
			if( [[_chat.remoteFriend status] length] > 0 )
				[self displayWarning:[NSString stringWithFormat:@"%@'s status changed to %@",[_chat.remoteFriend displayName],[_chat.remoteFriend status]]];
			else
				[self displayWarning:[NSString stringWithFormat:@"%@ is now Online",[_chat.remoteFriend displayName]]];
		}
			break;
			
		case XFFriendNotificationGameStatusChanged:
		{
			if( [_chat.remoteFriend gameID] > 0 )
			{
				[self displayWarning:[NSString stringWithFormat:@"%@ started playing %@",[_chat.remoteFriend displayName],[[BFGamesManager sharedGamesManager] longNameForGameID:[_chat.remoteFriend gameID]]]];
			}
			else
			{
				// TODO: Make this more advanced
				[self displayWarning:[NSString stringWithFormat:@"%@ stopped playing",[_chat.remoteFriend displayName]]];
			}
		}
			break;
			
		case XFFriendNotificationJoinedGameServer:
			//[self displayWarning:[NSString stringWithFormat:@"%@ joined a server on %@",[_chat.remoteFriend displayName],[_chat.remoteFriend gameIPString]]];
			break;
			
		case XFFriendNotificationLeftGameServer:
			//[self displayWarning:[NSString stringWithFormat:@"%@ left a server",[_chat.remoteFriend displayName]]];
			break;
			
		case XFFriendNotificationFriendAdded:
			break;
			
		case XFFriendNotificationFriendRemoved:
			break;
			
		case XFFriendNotificationFriendWillComeOnline:
			break;
			
		case XFFriendNotificationFriendWillGoOffline:
			break;
			
		default:
			break;
	}
	
	// TODO: Figure out whether this chat is the main chat
	[_windowController updateToolbar];
}


- (void)displayWarning:(NSString *)warningMessage
{
	if( [warningMessage length] > 0 )
	{
		NSString *timeStamp = @"";
		if([[NSUserDefaults standardUserDefaults] boolForKey:BFShowTimestamps])
			timeStamp = [_dateFormatter stringFromDate:[NSDate date]];
		[_webView newWarning:warningMessage timeStamp:timeStamp];
		
		BFMessage *message = [[BFMessage alloc] initWithMessage:warningMessage timestamp:[[NSDate date] timeIntervalSince1970] user:BFWarningMessageType];
		[_messages addObject:message];
	}
	/*if( [warningMessage length] > 0 )
	{
		NSMutableAttributedString *fmtMsg = nil;
		NSString *newline = @"", *timestamp = @"";
		
		if( [[_chatHistoryView textStorage] length] > 0 )
		{
			newline = @"\n";
		}
		
		if([[NSUserDefaults standardUserDefaults] boolForKey:BFShowTimestamps])
			timestamp = [_dateFormatter stringFromDate:[NSDate date]];
		
		NSFont *chatFont = [[NSFont fontWithName:@"Helvetica" size:12.0f] retain];
		NSFont *boldFont = [[[NSFontManager sharedFontManager] convertWeight:true ofFont:chatFont] retain];
		
		NSString *fmtMessage = [[NSString alloc] initWithFormat:@"%@%@ <%@>",newline,timestamp,warningMessage];
		fmtMsg = [[NSMutableAttributedString alloc] initWithString:fmtMessage];
		[fmtMessage release];
		
		[fmtMsg addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0, [fmtMsg length])];

		[fmtMsg addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedWhite:0.2f alpha:1.0f] range:NSMakeRange(0 ,[fmtMsg length])];
		
		AHHyperlinkScanner	*scanner = [[AHHyperlinkScanner alloc] initWithAttributedString:fmtMsg usingStrictChecking:NO];
		[[_chatHistoryView textStorage] appendAttributedString:[scanner linkifiedString]];
		[_chatHistoryView setNeedsDisplay:true];
		[scanner release];
		
		if( _windowController.currentChat == self )
			[self scrollAnimated:true];
		else
			[self scrollAnimated:false];
		
		
		[fmtMsg release];
		[boldFont release];
		[chatFont release];
		
		BFMessage *message = [[BFMessage alloc] initWithMessage:warningMessage timestamp:[[NSDate date] timeIntervalSince1970] user:BFWarningMessageType];
		[_messages addObject:message];
		[message release];
		
		
	}*/
}

- (void)processMessage:(NSString *)msg ofFriend:(NSString *)shortDispName ofType:(BFIMType)type
{
	NSDate *date = [NSDate date];
	NSString *timeStamp = @"";
	if([[NSUserDefaults standardUserDefaults] boolForKey:BFShowTimestamps])
		timeStamp = [_dateFormatter stringFromDate:date];
	if( ([date timeIntervalSince1970] - _lastTimestamp) >= TIMESTAMP_INTERVAL )
	{
		[_webView insertTimestamp:timeStamp];
	}
	_lastTimestamp = [date timeIntervalSince1970];
	if( type == BFFriendMessageType )
	{
		[_webView newMessage:msg ofType:true];
	}
	else {
		[_webView newMessage:msg ofType:false];
	}
	// determine this BEFORE we add the new message, otherwise the incoming message could be too big
	// which would disable the scrolling feature => SUCKS
	/*BOOL shouldScroll = [self shouldScroll];
	NSMutableAttributedString *fmtMsg;
	NSString *newline = @"", *timeStamp = @"";
	NSRange boldStyleRange = NSMakeRange(0, 0);
	
	if( [[_chatHistoryView textStorage] length] > 0 ) 
	{
		newline = @"\n";
		boldStyleRange.location += 1;
	}
	
	if([[NSUserDefaults standardUserDefaults] boolForKey:BFShowTimestamps])
		timeStamp = [_dateFormatter stringFromDate:[NSDate date]];
	
	boldStyleRange.length    = [shortDispName length] + 2 + [timeStamp length];  // the time plus name plus colon
	
	NSString *fmtMessage = [[NSString alloc] initWithFormat:@"%@%@ %@: %@",newline,timeStamp,shortDispName,msg];
	fmtMsg = [[NSMutableAttributedString alloc] initWithString:fmtMessage];
	[fmtMessage release];
	
	[fmtMsg addAttribute:NSFontAttributeName value:_chatFont range:NSMakeRange(0, [fmtMsg length])];
	[fmtMsg addAttribute:NSFontAttributeName value:_boldChatFont range:boldStyleRange];
	
	if( type == BFFriendMessageType )
		[fmtMsg addAttribute:NSForegroundColorAttributeName value:_friendColor range:boldStyleRange];
	else 
		[fmtMsg addAttribute:NSForegroundColorAttributeName value:_userColor range:boldStyleRange];
	
	[fmtMsg addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedWhite:0.2f alpha:1.0f] range:NSMakeRange([newline length], [timeStamp length])];
	
	AHHyperlinkScanner	*scanner = [[AHHyperlinkScanner alloc] initWithAttributedString:fmtMsg usingStrictChecking:NO];
    [[_chatHistoryView textStorage] appendAttributedString:[scanner linkifiedString]];
	[_chatHistoryView setNeedsDisplay:true];
	[scanner release];
	[fmtMsg release];
	
	if( shouldScroll )
	{
		if( _windowController.currentChat == self )
		{
			//[self performSelector:@selector(scrollAnimated:) withObject:[NSNumber numberWithBool:true] afterDelay:
			 //0.1f];
			[self scrollAnimated:false];
		}
		else
		{
			[self scrollAnimated:false];
		}
	}*/
}

- (void)scrollAnimated:(BOOL)animated
{
	[_webView scrollDown];
	/*if( animated )
	{
		NSClipView *clipView = [[_chatHistoryView enclosingScrollView] contentView];
		
		[NSAnimationContext beginGrouping];
		[[NSAnimationContext currentContext] setDuration:0.100f];
		NSPoint constrainedPoint = [clipView constrainScrollPoint:NSMakePoint(0, CGFLOAT_MAX)];
		[[clipView animator] setBoundsOrigin:constrainedPoint];
		[NSAnimationContext endGrouping];
	}
	else
	{
		NSRange range;
		range.location = [[_chatHistoryView textStorage] length];
		range.length = 1;
		[_chatHistoryView scrollRangeToVisible:range];
	}*/
}

- (BOOL)shouldScroll
{
	/*NSClipView *clipView	= [[_chatHistoryView enclosingScrollView] contentView];
	NSRect actualRect		= clipView.frame;
	NSRect documentRect		= clipView.documentRect;
	NSRect visibleRect		= clipView.documentVisibleRect;
	
	CGFloat difference = (documentRect.size.height-visibleRect.origin.y);
	if( difference < actualRect.size.height )
		return false;
	
	if( difference == actualRect.size.height )
	{
		return true;
	}
	else if( difference >= (actualRect.size.height+100) )
	{
		// annoying if you scroll here
		return false;
	}
	return true;*/
	return true;
}

@end
