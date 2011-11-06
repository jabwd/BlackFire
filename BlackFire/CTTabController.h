//
//  CTTabController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CTTabView, CTTabStripView;

@interface CTTabController : NSObject
{
	NSMutableArray *_tabs;
	
	CTTabStripView		*_tabStripView;
	CTTabView			*_placeholderTab;  // weak. Tab being dragged
	
	NSRect		_placeholderFrame;  // Frame to use
	NSRect		_droppedTabFrame;  // Initial frame of a dropped tab, for animation.
	
	CGFloat		_placeholderStretchiness; // Vertical force shown by streching tab.
	CGFloat		_availableResizeWidth;
	
	BOOL _initialLayoutComplete;
}

+ (CGFloat)minTabWidth;
+ (CGFloat)minSelectedTabWidth;
+ (CGFloat)maxTabWidth;
+ (CGFloat)miniTabWidth;
+ (CGFloat)appTabWidth;
+ (CGFloat)defaultTabHeight;
+ (CGFloat)defaultIndentForControls;


- (void)layoutTabsAnimated:(BOOL)animated;

@end
