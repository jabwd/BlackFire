//
//  BFChatTextFormatter.h
//  BlackFire
//
//  Created by Antwan van Houdt on 2/22/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BFChatLog;


@interface BFChatTextFormatter : NSObject
{
	BFChatLog *_chatLog;
}

- (id)initWithChatLog:(BFChatLog *)chatLog;

//---------------------------------------------------------------------------------
// Output

- (NSString *)plainTextFormat;

- (NSAttributedString *)attributedTextFormat;

@end
