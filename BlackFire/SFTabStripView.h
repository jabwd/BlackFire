//
//  SFTabStripView.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SFTabView;

@protocol TabStripDelegate <NSObject>
- (void)didSelectNewTab:(SFTabView *)tabView;
@end

@interface SFTabStripView : NSView
{
	NSMutableArray *_tabs;
	
	id <TabStripDelegate> _delegate;
}

@property (readonly) NSMutableArray *tabs;
@property (assign) id <TabStripDelegate> delegate;

//---------------------------------------------------------------------------------
// Laying out the tabs

- (void)selectTab:(SFTabView *)newSelected;


- (SFTabView *)tabViewForTag:(NSUInteger)tag;
- (void)addTabView:(SFTabView *)tabView;
- (void)removeTabView:(SFTabView *)tabView;

- (void)layoutTabs;
@end
