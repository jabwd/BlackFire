//
//  ADTableCellView.h
//  BlackFire
//
//  Created by Antwan van Houdt on 6/16/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ADTableCellView : NSTableCellView

@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) NSString *stringValue;
@property (nonatomic, strong) NSString *statusString;

@end
