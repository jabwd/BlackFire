//
//  ADModeSwitchView.h
//  TestApp
//
//  Created by Antwan van Houdt on 12/20/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ADModeSwitchView : NSView
{
	NSMutableArray *_items;
	
	SEL _selector;
	id _target;
}

@property (assign) SEL selector;
@property (assign) id target;

- (void)selectItemAtIndex:(NSUInteger)index;
- (NSInteger)selectedItemIndex;
@end
