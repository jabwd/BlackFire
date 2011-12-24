//
//  ADModeItem.h
//  TestApp
//
//  Created by Antwan van Houdt on 12/20/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADModeItem : NSObject

@property (nonatomic, retain) NSString	*name;
@property (nonatomic, assign) BOOL selected;

- (NSSize)size;

@end