//
//  ADStringPromptController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 12/7/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ADStringPromptController;

@protocol ADStringPromptDelegate <NSObject>
- (void)stringPromptDidCancel:(ADStringPromptController *)prompt;
- (void)stringPromptDidSucceed:(ADStringPromptController *)prompt;
- (void)stringPromptDidDefer:(ADStringPromptController *)prompt;
@end

@interface ADStringPromptController : NSObject

@property (unsafe_unretained) IBOutlet NSWindow	*sheet;
@property (unsafe_unretained) IBOutlet NSTextField *titleField;
@property (unsafe_unretained) IBOutlet NSTextField *messageField;

@property (unsafe_unretained) IBOutlet NSButton *cancelButton;
@property (unsafe_unretained) IBOutlet NSButton *doneButton;

@property (unsafe_unretained) id <ADStringPromptDelegate> delegate;

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
