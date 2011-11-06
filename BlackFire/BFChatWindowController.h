//
//  BFChatWindowController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BFChatWindowController : NSObject <NSWindowDelegate>
{
	NSWindow *_window;
}

@property (assign) IBOutlet NSWindow *window;

- (id)init;

@end
