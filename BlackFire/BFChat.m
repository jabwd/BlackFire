//
//  BFChat.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFChat.h"
#import "BFChatWindowController.h"
#import "BFNotificationCenter.h"

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
		_dateFormatter = [[NSDateFormatter alloc] init];
		[_dateFormatter setDateStyle:NSDateFormatterNoStyle];
		[_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendDidChange:) name:XFFriendDidChangeNotification object:chat.remoteFriend];
	}
	return self;
}

- (void)dealloc
{
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
	[_chat closeChat];
	[_chat release];
	_chat = nil;
}

#pragma mark - XFChat Delegate

- (void)receivedMessage:(NSString *)message
{
	[self processMessage:message ofFriend:[_chat.remoteFriend displayName] ofType:BFFriendMessageType];
	
	if( ![self.windowController.window isMainWindow] )
	{
		[[BFNotificationCenter defaultNotificationCenter] playReceivedSound];
		[[BFNotificationCenter defaultNotificationCenter] postNotificationWithTitle:[NSString stringWithFormat:@"Message from %@",[_chat.remoteFriend displayName]] body:message];
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

#pragma mark - Misc methods

- (void)friendDidChange:(NSNotification *)notification
{
	XFFriendNotification notificationType = [[[notification userInfo] objectForKey:@"type"] intValue];
	
	switch(notificationType)
	{
		case XFFriendNotificationOnlineStatusChanged:
		{
		}
			break;
			
		case XFFriendNotificationStatusChanged:
		{
		}
			break;
			
		case XFFriendNotificationGameStatusChanged:
		{
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
}

@end
