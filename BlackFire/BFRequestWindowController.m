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


- (id)initWithWindow:(NSWindow *)mainWindow
{
	if( (self = [super initWithWindow:mainWindow]) )
	{
		[NSBundle loadNibNamed:@"RequestWindow" owner:self];
	}
	return self;
}


- (void)fillWithXfireFriend:(XFFriend *)remoteFriend
{
	self.titleField.stringValue			= [remoteFriend displayName];
	self.messageField.stringValue		= remoteFriend.status;
	
	_remoteFriend = remoteFriend;
}

- (IBAction)defer:(id)sender
{
	if( [self.delegate respondsToSelector:@selector(stringPromptDidDefer:)] )
		[self.delegate stringPromptDidDefer:self];
}

@end
