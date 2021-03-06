//
//  BFAddGameSheetController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 12/27/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import "BFAddGameSheetController.h"

@implementation BFAddGameSheetController


- (id)initWithWindow:(NSWindow *)mainWindow
{
	if( (self = [super initWithWindow:mainWindow]) )
	{
		[NSBundle loadNibNamed:@"AddGameSheet" owner:self];
		[_dropField setDelegate:self];
	}
	return self;
}

- (void)dealloc
{
	[_dropField setDelegate:nil];
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
