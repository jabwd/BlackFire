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

#import "AHHyperlinkScanner.h"

@implementation BFChat

@synthesize windowController	= _windowController;
@synthesize chatHistoryView		= _chatHistoryView;
@synthesize chatScrollView		= _chatScrollView;

@synthesize missedMessages		= _missedMessages;

@synthesize chat = _chat;

- (id)initWithChat:(XFChat *)chat
{
	if( (self = [super init]) )
	{
		[NSBundle loadNibNamed:@"BFChat" owner:self];
		_chat = [chat retain];
		_missedMessages = 0;
		_dateFormatter = [[NSDateFormatter alloc] init];
		[_dateFormatter setDateStyle:NSDateFormatterNoStyle];
		[_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		_typing			= false;
		_animating		= false;
		
		_userColor		= [[NSColor blueColor] retain];
		_friendColor	= [[NSColor redColor] retain];
		_chatFont		= [[NSFont fontWithName:@"Lucida Grande" size:12.0f] retain];
		_boldChatFont	= [[[NSFontManager sharedFontManager] convertWeight:true ofFont:_chatFont] retain];
		
		_messages = [[NSMutableArray alloc] init];
	
		
		if( ! chat.remoteFriend )
		{
			NSLog(@"*** No remotefriend object 0x589129");
		}
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendDidChange:) name:XFFriendDidChangeNotification object:chat.remoteFriend];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatNotificationWasClicked:) name:@"chatFriendClicked" object:chat.remoteFriend];
		
		if( [[NSUserDefaults standardUserDefaults] boolForKey:BFEnableChatHistory] )
		{
			BFChatLog *chatLog = [[BFChatLog alloc] init];
			chatLog.friendUsername = _chat.remoteFriend.username;
			NSArray *messages = [chatLog getLastMessages:5];
			NSMutableString *str = [[NSMutableString alloc] init];
			NSUInteger i, cnt = [messages count];
			for(i=cnt;i>0;i--)
			{
				BFMessage *message = [messages objectAtIndex:(i-1)];
				NSString *newLine = @"";
				if( [str length] > 0 )
					newLine = @"\n";
				NSString *timestamp = @"";
				if( [[NSUserDefaults standardUserDefaults] boolForKey:BFShowTimestamps] )
					timestamp = [_dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:message.timestamp]];
				if( message.user != BFWarningMessageType )
				{
					NSString *displayName = nil;
					if( message.user == BFFriendMessageType )
						displayName = [_chat.remoteFriend displayName];
					else
						displayName = [[_chat loginIdentity] displayName];
					[str appendFormat:@"%@%@ %@: %@",newLine,timestamp,displayName,message.message];
				}
				else
				{
					[str appendFormat:@"%@%@ <%@>",newLine,timestamp,message.message];
				}
			}
			NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:_chatFont,NSFontAttributeName,[NSColor darkGrayColor],NSForegroundColorAttributeName, nil];
			NSAttributedString *string = [[NSAttributedString alloc] initWithString:str attributes:attributes];
			[[_chatHistoryView textStorage] setAttributedString:string];
			[attributes release];
			[string release];
			[str release];
			[chatLog release];
		}
	}
	return self;
}

- (void)dealloc
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_chat setDelegate:nil];
	[_chat release];
	_chat = nil;
	[_messages release];
	_messages = nil;
	[_windowController release];
	_windowController = nil;
	[_dateFormatter release];
	_dateFormatter = nil;
	[_userColor release];
	_userColor = nil;
	[_friendColor release];
	_friendColor = nil;
	[_chatFont release];
	_chatFont = nil;
	[_boldChatFont release];
	_boldChatFont = nil;
	[super dealloc];
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
		[chatLog release];
	}
	
	[_messages release];
	_messages = nil;
	
	SFTabView *tab = [_windowController tabViewForChat:self];
	tab.missedMessages = _missedMessages;
	[tab setNeedsDisplay:true]; // reset the missed messages count
	[_chat setDelegate:nil];
	[_chat closeChat];
	[_chat release];
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
	[msg release];
	
	if( ![self.windowController.window isMainWindow] || _windowController.currentChat != self )
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
}

- (void)sendMessage:(NSString *)message
{
	if( [message length] < 1 || [message length] > 4000 )
		return;
	
	[self processMessage:message ofFriend:[[_chat loginIdentity] displayName] ofType:BFUserMessageType];
	
	[_chat sendMessage:message];

	BFMessage *msg = [[BFMessage alloc] initWithMessage:message timestamp:[[NSDate date] timeIntervalSince1970] user:BFUserMessageType];
	[_messages addObject:msg];
	[msg release];
	
	[[BFNotificationCenter defaultNotificationCenter] playSendSound];
}

- (void)friendStartedTyping
{
	[_windowController tabViewForChat:self].image = [NSImage imageNamed:@"tab-typing"];
	[[_windowController tabViewForChat:self] setNeedsDisplay:true];
}

- (void)friendStoppedTyping
{
	[_windowController tabViewForChat:self].image = nil;
	[[_windowController tabViewForChat:self] setNeedsDisplay:true];
}

#pragma mark - Misc methods

- (void)textDidChange:(NSNotification *)notification
{
	if( ! _typing )
	{
		_typing = true;
		[_chat sendTypingNotification];
		[self performSelector:@selector(userTypingDidEnd) withObject:nil afterDelay:5.0f];
	}
}

- (void)userTypingDidEnd
{
	_typing = false;
}

- (void)friendDidChange:(NSNotification *)notification
{
	XFFriendNotification notificationType = [[[notification userInfo] objectForKey:@"type"] intValue];
	
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
			[self displayWarning:[NSString stringWithFormat:@"%@ joined a server on %@",[_chat.remoteFriend displayName],[_chat.remoteFriend gameIPString]]];
			break;
			
		case XFFriendNotificationLeftGameServer:
			[self displayWarning:[NSString stringWithFormat:@"%@ left a server",[_chat.remoteFriend displayName]]];
			break;
			
		case XFFriendNotificationFriendAdded:
		{
		}
			break;
			
		case XFFriendNotificationFriendRemoved:
		{
		}
			break;
	}
	
	// TODO: Figure out whether this chat is the main chat
	[_windowController updateToolbar];
}


- (void)displayWarning:(NSString *)warningMessage
{
	if( [warningMessage length] > 0 )
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
		
		
	}
}

- (void)processMessage:(NSString *)msg ofFriend:(NSString *)shortDispName ofType:(BFIMType)type
{
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
	
	if( _windowController.currentChat == self )
		[self scrollAnimated:true];
	else
		[self scrollAnimated:false];
}

- (void)scrollAnimated:(BOOL)animated
{
	if( [self shouldScroll] )
	{
		if( animated )
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
		}
	}
}

- (BOOL)shouldScroll
{
	// TODO: Make this work properly.
	return true;
	NSClipView *clipView	= [[_chatHistoryView enclosingScrollView] contentView];
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
	return true;
}

@end
