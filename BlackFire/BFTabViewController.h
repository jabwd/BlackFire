//
//  BFTabViewController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/5/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ADAppDelegate, BFInfoViewController;

@interface BFTabViewController : NSObject

@property (unsafe_unretained) IBOutlet NSView *view;
@property (unsafe_unretained) ADAppDelegate *delegate;


/*
 * The info view controller should be created by a subclass to represent whatever view controller
 * the subclass needs to display its extra information. The subclass is also responsible for controlling
 * any data related to that view controller and its view
 */
@property (strong) BFInfoViewController *infoViewController;

- (void)becomeMain;

- (void)resignMain;

@end
