//
//  BFSetupWindowController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/5/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol BFSetupWindowControllerDelegate <NSObject>
- (void)setupWindowClosed;
@end

@interface BFSetupWindowController : NSObject <NSWindowDelegate>
{
	NSWindow *_window;
	
	NSButton *_nextButton;
	NSButton *_previousButton;
	
	NSBox  *_mainView;
	NSView *_accountInfoView;
	NSView *_settingsView;
	NSView *_finishedView;
	
	id <BFSetupWindowControllerDelegate> _delegate;
	
	unsigned int _currentMode;
}

@property (nonatomic, assign) id <BFSetupWindowControllerDelegate> delegate;
@property (nonatomic, assign) IBOutlet NSWindow *window;

@property (nonatomic, assign) IBOutlet NSButton *nextButton;
@property (nonatomic, assign) IBOutlet NSButton *previousButton;

@property (nonatomic, assign) IBOutlet NSBox  *mainView;
@property (nonatomic, assign) IBOutlet NSView *accountInfoView;
@property (nonatomic, assign) IBOutlet NSView *settingsView;
@property (nonatomic, assign) IBOutlet NSView *finishedView;

- (id)initWithWindowNibName:(NSString *)windowNibName;

- (IBAction)next:(id)sender;
- (IBAction)previous:(id)sender;

@end
