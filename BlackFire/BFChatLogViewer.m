//
//  BFChatLogViewer.m
//  BlackFire
//
//  Created by Antwan van Houdt on 2/3/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "BFChatLogViewer.h"
#import "BFApplicationSupport.h"
#import "BFChatLog.h"

@implementation BFChatLogViewer

@synthesize friendsList = _friendsList;
@synthesize chatlogList	= _chatlogList;
@synthesize chatlogView	= _chatlogView;

- (id)init
{
	if( (self = [super initWithWindowNibName:@"ChatLogViewer"]) )
	{
		
	}
	return self;
}

- (void)dealloc
{
	[_friends release];
	_friends = nil;
	[super dealloc];
}

- (void)awakeFromNib
{
	
}

- (IBAction)showWindow:(id)sender
{
	[self.window makeKeyAndOrderFront:self];
}

#pragma mark - Toolbar buttons

- (IBAction)cleanOldChatlogs:(id)sender
{
	
}

- (IBAction)cleanAllChatlogs:(id)sender
{
	NSString *dirPath = BFChatLogDirectoryPath();
	NSString *trashDir = [NSHomeDirectory() stringByAppendingPathComponent:@".Trash"];
	int tag;
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
	if( [contents count] > 0 )
	{
		[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation source:dirPath destination:trashDir files:contents tag:&tag];
	}
}

- (IBAction)saveChatlog:(id)sender
{
	
}

@end
