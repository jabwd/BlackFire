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

#import "BFGamesManager.h"

#import "XFSession.h"
#import "XFFriend.h"

#import "AHHyperlinkScanner.h"

@implementation BFChat

@synthesize windowController	= _windowController;
@synthesize chatHistoryView  = _chatHistoryView;
@synthesize chatScrollView = _chatScrollView;

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
		_typing = false;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendDidChange:) name:XFFriendDidChangeNotification object:chat.remoteFriend];
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
	[_windowController release];
	_windowController = nil;
	[_dateFormatter release];
	_dateFormatter = nil;
	[super dealloc];
}

- (void)closeChat
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_missedMessages = 0;
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
	_missedMessages = 0;
	SFTabView *tab = [_windowController tabViewForChat:self];
	tab.missedMessages = _missedMessages;
	[tab setNeedsDisplay:true];
}

#pragma mark - XFChat Delegate

- (void)receivedMessage:(NSString *)message
{
	[self processMessage:message ofFriend:[_chat.remoteFriend displayName] ofType:BFFriendMessageType];
	
	if( ![self.windowController.window isMainWindow] || _windowController.currentChat != self )
	{
		[[BFNotificationCenter defaultNotificationCenter] playReceivedSound];
		[[BFNotificationCenter defaultNotificationCenter] postNotificationWithTitle:[NSString stringWithFormat:@"Message from %@",[_chat.remoteFriend displayName]] body:message];
		[[NSApplication sharedApplication] requestUserAttention:10];
		_missedMessages++;
		SFTabView *tab = [_windowController tabViewForChat:self];
		tab.missedMessages = _missedMessages;
		[tab setNeedsDisplay:true];
	}
}

- (void)sendMessage:(NSString *)message
{
	if( [message length] < 1 || [message length] > 4000 )
		return;
	
	[self processMessage:message ofFriend:[[_chat loginIdentity] displayName] ofType:BFUserMessageType];
	
	[_chat sendMessage:message];
	
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
		
		if([[NSUserDefaults standardUserDefaults] boolForKey:@"enableTimeStamps"])
			timestamp = [_dateFormatter stringFromDate:[NSDate date]];
		
		NSFont *chatFont = [[NSFont fontWithName:@"Helvetica" size:12.0f] retain];
		NSFont *boldFont = [[[NSFontManager sharedFontManager] convertWeight:true ofFont:chatFont] retain];
		
		NSString *fmtMessage = [[NSString alloc] initWithFormat:@"%@%@ <%@>",newline,timestamp,warningMessage];
		fmtMsg = [[NSMutableAttributedString alloc] initWithString:fmtMessage];
		[fmtMessage release];
		
		[fmtMsg addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0, [fmtMsg length])];

		[fmtMsg addAttribute:NSForegroundColorAttributeName value:[NSColor darkGrayColor] range:NSMakeRange(0 ,[fmtMsg length])];
		
		AHHyperlinkScanner	*scanner = [[AHHyperlinkScanner alloc] initWithAttributedString:fmtMsg usingStrictChecking:NO];
		[[_chatHistoryView textStorage] appendAttributedString:[scanner linkifiedString]];
		[_chatHistoryView setNeedsDisplay:true];
		NSRange range;
		range.location = [[_chatHistoryView textStorage] length];
		range.length = 1;
		[_chatHistoryView scrollRangeToVisible:range];
		[scanner release];
		
		
		[fmtMsg release];
		[boldFont release];
		[chatFont release];
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
	
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"enableTimeStamps"])
		timeStamp = [_dateFormatter stringFromDate:[NSDate date]];
	
	NSFont *chatFont		= [[NSFont fontWithName:@"Helvetica" size:12.0f] retain];
	NSFont *boldFont		= [[[NSFontManager sharedFontManager] convertWeight:YES ofFont:chatFont] retain];
	
	boldStyleRange.length    = [shortDispName length] + 2 + [timeStamp length];  // the time plus name plus colon
	
	NSString *fmtMessage = [[NSString alloc] initWithFormat:@"%@%@ %@: %@",newline,timeStamp,shortDispName,msg];
	fmtMsg = [[NSMutableAttributedString alloc] initWithString:fmtMessage];
	[fmtMessage release];
	
	[fmtMsg addAttribute:NSFontAttributeName value:chatFont range:NSMakeRange(0, [fmtMsg length])];
	[fmtMsg addAttribute:NSFontAttributeName value:boldFont range:boldStyleRange];
	
	if( type == BFFriendMessageType )
		[fmtMsg addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:boldStyleRange];
	else 
		[fmtMsg addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:boldStyleRange];
	
	[fmtMsg addAttribute:NSForegroundColorAttributeName value:[NSColor darkGrayColor] range:NSMakeRange([newline length], [timeStamp length])];
	
	AHHyperlinkScanner	*scanner = [[AHHyperlinkScanner alloc] initWithAttributedString:fmtMsg usingStrictChecking:NO];
    [[_chatHistoryView textStorage] appendAttributedString:[scanner linkifiedString]];
	[_chatHistoryView setNeedsDisplay:true];
	NSRange range;
	range.location = [[_chatHistoryView textStorage] length];
	range.length = 1;
	[_chatHistoryView scrollRangeToVisible:range];
	[scanner release];
	[fmtMsg release];
	
	[chatFont release];
	[boldFont release];
}

@end
