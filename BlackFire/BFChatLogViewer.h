//
//  BFChatLogViewer.h
//  BlackFire
//
//  Created by Antwan van Houdt on 2/3/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BFChatLog;

@interface BFChatLogViewer : NSWindowController
{
	NSMutableArray	*_friends;
	BFChatLog		*_currentChatLog;
}

@property (assign) IBOutlet NSTextView *chatlogView;
@property (assign) IBOutlet NSTableView *friendsList;
@property (assign) IBOutlet NSTableView *chatlogList;

- (IBAction)showWindow:(id)sender;

- (IBAction)cleanOldChatlogs:(id)sender;
- (IBAction)cleanAllChatlogs:(id)sender;
- (IBAction)saveChatlog:(id)sender;

@end
