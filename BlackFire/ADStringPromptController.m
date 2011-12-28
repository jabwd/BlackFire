//
//  ADStringPromptController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 12/7/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "ADStringPromptController.h"

@implementation ADStringPromptController

@synthesize sheet			= _sheet;
@synthesize titleField		= _titleField;
@synthesize messageField	= _messageField;

@synthesize cancelButton	= _cancelButton;
@synthesize doneButton		= _doneButton;

@synthesize delegate		= _delegate;

- (id)initWithWindow:(NSWindow *)mainWindow
{
	if( (self = [super init]) )
	{
		_mainWindow = mainWindow;
		
		[NSBundle loadNibNamed:@"StringPrompt" owner:self];
	}
	return self;
}

- (void)dealloc
{
	_titleField		= nil;
	_doneButton		= nil;
	_cancelButton	= nil;
	_messageField	= nil;
	_sheet			= nil;
	_mainWindow		= nil;
	_delegate		= nil;
	[super dealloc];
}

#pragma mark - Controlling the sheet

- (void)show
{
	if( _mainWindow )
	{
		[NSApp beginSheet:_sheet modalForWindow:_mainWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
	}
	else
	{
		NSLog(@"*** Cannot show stringprompt without a valid mainwindow reference");
	}
}

- (void)hide
{
	[NSApp endSheet:_sheet];
	[_sheet orderOut:self];
}


#pragma mark - User interface controls

- (IBAction)cancelAction:(id)sender
{
	[self hide];
	if( [_delegate respondsToSelector:@selector(stringPromptDidCancel:)] )
		[_delegate stringPromptDidCancel:self];
}

- (IBAction)doneAction:(id)sender
{
	[self hide];
	if( [_delegate respondsToSelector:@selector(stringPromptDidSucceed:)] )
		[_delegate stringPromptDidSucceed:self];
}

@end
