//
//  ADAppDelegate.h
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XFSession.h"

@interface ADAppDelegate : NSObject <NSApplicationDelegate, XFSessionDelegate>

@property (assign) IBOutlet NSWindow *window;

@end
