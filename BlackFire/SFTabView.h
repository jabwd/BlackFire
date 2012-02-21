//
//  SFTabView.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/7/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SFTabStripView;

@interface SFTabView : NSView
{
	SFTabStripView *_tabStrip;
	NSString *_title;
	NSImage *_tabImage;
	
	id _target;
	SEL _selector;
	
	NSRect _originalRect;
	NSPoint _originalPoint;
	
	NSInteger _tag;
	
	NSUInteger _missedMessages;
	
	BOOL _selected;
	BOOL _mouseInside;
	BOOL _dragging;
	BOOL _mouseInsideClose;
	BOOL _mouseDownInsideClose;
	
	BOOL _tabDragAction;
	BOOL _tabRightSide; // used for the drawing, set in layoutTabs of the tabstripview
}

@property (nonatomic, assign) SFTabStripView *tabStrip;

@property (nonatomic, retain) NSString *title;
@property (assign) NSInteger tag;
@property (nonatomic, retain) NSImage *image;

@property (assign) id target;
@property (assign) SEL selector;

@property (assign) NSUInteger missedMessages;

@property (assign) BOOL selected;
@property (assign) BOOL tabDragAction;
@property (assign) BOOL tabRightSide;

@end
