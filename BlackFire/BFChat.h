//
//  BFChat.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XFChat.h"

@interface BFChat : NSObject <XFChatDelegate, NSTableViewDataSource, NSTableViewDelegate>
{
	XFChat *_chat;
}

- (id)initWithChat:(XFChat *)chat;
@end
