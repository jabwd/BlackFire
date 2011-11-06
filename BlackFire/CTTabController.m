//
//  CTTabController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "CTTabController.h"
#import "CTTabStripView.h"
#import "CTTabView.h"

// The images names used for different states of the new tab button.
static NSImage* kNewTabHoverImage = nil;
static NSImage* kNewTabImage = nil;
static NSImage* kNewTabPressedImage = nil;

// Image used to display default icon (when contents.hasIcon && !contents.icon)
static NSImage* kDefaultIconImage = nil;

// A value to indicate tab layout should use the full available width of the
// view.
const CGFloat kUseFullAvailableWidth = -1.0;

// The amount by which tabs overlap.
const CGFloat kTabOverlap = 20.0;

// The width and height for a tab's icon.
const CGFloat kIconWidthAndHeight = 16.0;

// The amount by which the new tab button is offset (from the tabs).
const CGFloat kNewTabButtonOffset = 8.0;

// Time (in seconds) in which tabs animate to their final position.
const NSTimeInterval kAnimationDuration = 0.125;

@implementation CTTabController


+ (CGFloat)minTabWidth				{ return 31;	}
+ (CGFloat)minSelectedTabWidth		{ return 46;	}
+ (CGFloat)maxTabWidth				{ return 220;	}
+ (CGFloat)miniTabWidth				{ return 53;	}
+ (CGFloat)appTabWidth				{ return 66;	}
+ (CGFloat)defaultTabHeight			{ return 25.0; }
+ (CGFloat)defaultIndentForControls { return 64.0; }
/*

- (BOOL)isTabFullyVisible:(CTTabView*)tab 
{
	NSRect frame = [tab frame];
	return NSMinX(frame) >= [self indentForControls] &&
	NSMaxX(frame) <= NSMaxX([_tabStripView frame]);
}

- (void)layoutTabsAnimated:(BOOL)animated
{
	assert([NSThread isMainThread]);
	if (![tabArray_ count])
		return;
	
	const CGFloat kMaxTabWidth = [CTTabController maxTabWidth];
	const CGFloat kMinTabWidth = [CTTabController minTabWidth];
	const CGFloat kMinSelectedTabWidth = [CTTabController minSelectedTabWidth];
	const CGFloat kMiniTabWidth = [CTTabController miniTabWidth];
	const CGFloat kAppTabWidth = [CTTabController appTabWidth];
	
	NSRect enclosingRect = NSZeroRect;
	ScopedNSAnimationContextGroup mainAnimationGroup(animate);
	mainAnimationGroup.SetCurrentContextDuration(kAnimationDuration);
	
	// Update the current subviews and their z-order if requested.
	if (doUpdate)
		[self regenerateSubviewList];
	
	// Compute the base width of tabs given how much room we're allowed. Note that
	// mini-tabs have a fixed width. We may not be able to use the entire width
	// if the user is quickly closing tabs. This may be negative, but that's okay
	// (taken care of by |MAX()| when calculating tab sizes).
	CGFloat availableSpace = 0;
	if (verticalLayout_) {
		availableSpace = NSHeight([tabStripView_ bounds]);
	} else {
		if ([self inRapidClosureMode]) {
			availableSpace = availableResizeWidth_;
		} else {
			availableSpace = NSWidth([tabStripView_ frame]);
			// Account for the new tab button and the incognito badge.
			if (forceNewTabButtonHidden_) {
				availableSpace -= 5.0; // margin
			} else {
				availableSpace -= NSWidth([newTabButton_ frame]) + kNewTabButtonOffset;
			}
		}
		availableSpace -= [self indentForControls];
	}
	
	// This may be negative, but that's okay (taken care of by |MAX()| when
	// calculating tab sizes). "mini" tabs in horizontal mode just get a special
	// section, they don't change size.
	CGFloat availableSpaceForNonMini = availableSpace;
	if (!verticalLayout_) {
		availableSpaceForNonMini -=
		[self numberOfOpenMiniTabs] * (kMiniTabWidth - kTabOverlap);
	}
	
	// Initialize |nonMiniTabWidth| in case there aren't any non-mini-tabs; this
	// value shouldn't actually be used.
	CGFloat nonMiniTabWidth = kMaxTabWidth;
	const NSInteger numberOfOpenNonMiniTabs = [self numberOfOpenNonMiniTabs];
	if (!verticalLayout_ && numberOfOpenNonMiniTabs) {
		// Find the width of a non-mini-tab. This only applies to horizontal
		// mode. Add in the amount we "get back" from the tabs overlapping.
		availableSpaceForNonMini += (numberOfOpenNonMiniTabs - 1) * kTabOverlap;
		
		// Divide up the space between the non-mini-tabs.
		nonMiniTabWidth = availableSpaceForNonMini / numberOfOpenNonMiniTabs;
		
		// Clamp the width between the max and min.
		nonMiniTabWidth = MAX(MIN(nonMiniTabWidth, kMaxTabWidth), kMinTabWidth);
	}
	
	BOOL visible = [[tabStripView_ window] isVisible];
	
	CGFloat offset = [self indentForControls];
	NSUInteger i = 0;
	bool hasPlaceholderGap = false;
	for (CTTabController* tab in tabArray_.get()) {
		// Ignore a tab that is going through a close animation.
		if ([closingControllers_ containsObject:tab])
			continue;
		
		BOOL isPlaceholder = [[tab view] isEqual:placeholderTab_];
		NSRect tabFrame = [[tab view] frame];
		tabFrame.size.height = [[self class] defaultTabHeight] + 1;
		if (verticalLayout_) {
			tabFrame.origin.y = availableSpace - tabFrame.size.height - offset;
			tabFrame.origin.x = 0;
		} else {
			tabFrame.origin.y = 0;
			tabFrame.origin.x = offset;
		}
		// If the tab is hidden, we consider it a new tab. We make it visible
		// and animate it in.
		BOOL newTab = [[tab view] isHidden];
		if (newTab) {
			[[tab view] setHidden:NO];
		}
		
		if (isPlaceholder) {
			// Move the current tab to the correct location instantly.
			// We need a duration or else it doesn't cancel an inflight animation.
			ScopedNSAnimationContextGroup localAnimationGroup(animate);
			localAnimationGroup.SetCurrentContextShortestDuration();
			if (verticalLayout_)
				tabFrame.origin.y = availableSpace - tabFrame.size.height - offset;
			else
				tabFrame.origin.x = placeholderFrame_.origin.x;
			// TODO(alcor): reenable this
			//tabFrame.size.height += 10.0 * placeholderStretchiness_;
			id target = animate ? [[tab view] animator] : [tab view];
			[target setFrame:tabFrame];
			
			// Store the frame by identifier to aviod redundant calls to animator.
			NSValue* identifier = [NSValue valueWithPointer:[tab view]];
			[targetFrames_ setObject:[NSValue valueWithRect:tabFrame]
							  forKey:identifier];
			continue;
		}
		
		if (placeholderTab_ && !hasPlaceholderGap) {
			const CGFloat placeholderMin =
			verticalLayout_ ? NSMinY(placeholderFrame_) :
			NSMinX(placeholderFrame_);
			if (verticalLayout_) {
				if (NSMidY(tabFrame) > placeholderMin) {
					hasPlaceholderGap = true;
					offset += NSHeight(placeholderFrame_);
					tabFrame.origin.y = availableSpace - tabFrame.size.height - offset;
				}
			} else {
				// If the left edge is to the left of the placeholder's left, but the
				// mid is to the right of it slide over to make space for it.
				if (NSMidX(tabFrame) > placeholderMin) {
					hasPlaceholderGap = true;
					offset += NSWidth(placeholderFrame_);
					offset -= kTabOverlap;
					tabFrame.origin.x = offset;
				}
			}
		}
		
		// Set the width. Selected tabs are slightly wider when things get really
		// small and thus we enforce a different minimum width.
		tabFrame.size.width = [tab mini] ?
        ([tab app] ? kAppTabWidth : kMiniTabWidth) : nonMiniTabWidth;
		if ([tab selected])
			tabFrame.size.width = MAX(tabFrame.size.width, kMinSelectedTabWidth);
		
		// Animate a new tab in by putting it below the horizon unless told to put
		// it in a specific location (i.e., from a drop).
		// TODO(pinkerton): figure out vertical tab animations.
		if (newTab && visible && animate) {
			if (NSEqualRects(droppedTabFrame_, NSZeroRect)) {
				[[tab view] setFrame:NSOffsetRect(tabFrame, 0, -NSHeight(tabFrame))];
			} else {
				[[tab view] setFrame:droppedTabFrame_];
				droppedTabFrame_ = NSZeroRect;
			}
		}
		
		// Check the frame by identifier to avoid redundant calls to animator.
		id frameTarget = visible && animate ? [[tab view] animator] : [tab view];
		NSValue* identifier = [NSValue valueWithPointer:[tab view]];
		NSValue* oldTargetValue = [targetFrames_ objectForKey:identifier];
		if (!oldTargetValue ||
			!NSEqualRects([oldTargetValue rectValue], tabFrame)) {
			[frameTarget setFrame:tabFrame];
			[targetFrames_ setObject:[NSValue valueWithRect:tabFrame]
							  forKey:identifier];
		}
		
		enclosingRect = NSUnionRect(tabFrame, enclosingRect);
		
		if (verticalLayout_) {
			offset += NSHeight(tabFrame);
		} else {
			offset += NSWidth(tabFrame);
			offset -= kTabOverlap;
		}
		i++;
	}
	
	[dragBlockingView_ setFrame:enclosingRect];
	
	// Mark that we've successfully completed layout of at least one tab.
	initialLayoutComplete_ = YES;
}*/

@end
