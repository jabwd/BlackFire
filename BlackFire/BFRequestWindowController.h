//
//  BFRequestWindowController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 12/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ADStringPromptController.h"

@class XFFriend;

@interface BFRequestWindowController : ADStringPromptController
{
	XFFriend *_remoteFriend;
}

@property (nonatomic, strong) XFFriend *remoteFriend;

- (IBAction)defer:(id)sender;

- (void)fillWithXfireFriend:(XFFriend *)remoteFriend;

@end
