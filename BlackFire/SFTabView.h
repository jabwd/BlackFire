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

@property (nonatomic, unsafe_unretained) SFTabStripView *tabStrip;
@property (nonatomic, strong) NSString *title;
@property (assign) NSInteger tag;
@property (readonly) BOOL animating;
@property (readonly) NSRect proposedLocation;
@property (nonatomic, strong) NSImage *image;
@property (unsafe_unretained) id target;
@property (assign) SEL selector;
@property (assign) NSUInteger missedMessages;
@property (assign) BOOL selected;
@property (assign) BOOL tabDragAction;
@property (assign) BOOL tabRightSide;

/*
 * This animates the tabview to the new location
 * and when animating stops the current animation and 
 * starts moving again 
 */
- (void)moveToFrame:(NSRect)newFrame;

@end
