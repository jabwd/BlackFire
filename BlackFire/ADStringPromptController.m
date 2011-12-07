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
	
}

- (IBAction)doneAction:(id)sender
{
	
}

@end
