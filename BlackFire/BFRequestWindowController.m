//
//  BFRequestWindowController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 12/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BFRequestWindowController.h"
#import "XFFriend.h"

@implementation BFRequestWindowController

@synthesize remoteFriend = _remoteFriend;

- (id)initWithWindow:(NSWindow *)mainWindow
{
	if( (self = [super init]) )
	{
		_mainWindow = mainWindow;
		
		[NSBundle loadNibNamed:@"RequestWindow" owner:self];
	}
	return self;
}

- (void)dealloc
{
	[_remoteFriend release];
	_remoteFriend = nil;
	[super dealloc];
}

- (void)fillWithXfireFriend:(XFFriend *)remoteFriend
{
	self.titleField.stringValue			= [remoteFriend displayName];
	self.messageField.stringValue		= remoteFriend.status;
	
	[_remoteFriend release];
	_remoteFriend = [remoteFriend retain];
}

- (IBAction)defer:(id)sender
{
	if( [_delegate respondsToSelector:@selector(stringPromptDidDefer:)] )
		[_delegate stringPromptDidDefer:self];
}

@end
