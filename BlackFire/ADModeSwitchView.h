//
//  ADModeSwitchView.h
//  TestApp
//
//  Created by Antwan van Houdt on 12/20/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ADModeSwitchView : NSView

@property (assign) SEL selector;
@property (unsafe_unretained) id target;

- (void)selectItemAtIndex:(NSInteger)index;
- (NSInteger)selectedItemIndex;
@end
