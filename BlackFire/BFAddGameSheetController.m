//
//  BFAddGameSheetController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 12/27/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import "BFAddGameSheetController.h"

@implementation BFAddGameSheetController

@synthesize dropField = _dropField;

- (id)initWithWindow:(NSWindow *)mainWindow
{
	if( (self = [super init]) )
	{
		[NSBundle loadNibNamed:@"AddGameSheet" owner:self];
		
		_mainWindow = mainWindow;
		[_dropField setDelegate:self];
	}
	return self;
}

- (void)dealloc
{
	[_dropField setDelegate:nil];
	_mainWindow = nil;
	[super dealloc];
}

- (IBAction)cancelAction:(id)sender
{
	[_dropField setDelegate:nil];
	[super cancelAction:sender];
}

- (IBAction)doneAction:(id)sender
{
	[_dropField setDelegate:nil];
	[super doneAction:sender];
}

- (void)applicationPathChanged:(NSString *)newPath
{
	[self doneAction:nil];
}
@end
