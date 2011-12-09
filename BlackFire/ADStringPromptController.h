//
//  ADStringPromptController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 12/7/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADStringPromptController;

@protocol ADStringPromptDelegate <NSObject>
- (void)stringPromptDidCancel:(ADStringPromptController *)prompt;
- (void)stringPromptDidSucceed:(ADStringPromptController *)prompt;
@end

@interface ADStringPromptController : NSObject
{
	NSWindow *_mainWindow;
	
	id <ADStringPromptDelegate> _delegate;
}

@property (assign) IBOutlet NSWindow	*sheet;
@property (assign) IBOutlet NSTextField *titleField;
@property (assign) IBOutlet NSTextField *messageField;

@property (assign) IBOutlet NSButton *cancelButton;
@property (assign) IBOutlet NSButton *doneButton;

@property (assign) id <ADStringPromptDelegate> delegate;

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
