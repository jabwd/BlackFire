//
//  SFTabStripView.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SFTabView;

@interface SFTabStripView : NSView
{
	NSMutableArray *_tabs;
}

@property (readonly) NSMutableArray *tabs;

//---------------------------------------------------------------------------------
// Laying out the tabs

- (void)selectTab:(SFTabView *)newSelected;


- (void)addTabView:(SFTabView *)tabView;

- (void)layoutTabs;
@end
