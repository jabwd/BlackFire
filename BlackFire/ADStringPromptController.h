//
//  ADStringPromptController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 12/7/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADStringPromptController : NSObject
{
	NSWindow *_mainWindow;
}

@property (assign) IBOutlet NSWindow	*sheet;
@property (assign) IBOutlet NSTextField *titleField;
@property (assign) IBOutlet NSTextField *messageField;

@property (assign) IBOutlet NSButton *cancelButton;
@property (assign) IBOutlet NSButton *doneButton;

- (id)initWithWindow:(NSWindow *)mainWindow;

//-----------------------------------------------------------------------------
// Controlling the sheet

- (void)show;
- (void)hide;

//-----------------------------------------------------------------------------
// User interface controls

- (IBAction)cancelAction:(id)sender;
- (IBAction)doneAction:(id)sender;

@end
