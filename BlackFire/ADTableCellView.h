//
//  ADTableCellView.h
//  BlackFire
//
//  Created by Antwan van Houdt on 6/16/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ADTableCellView : NSTableCellView
{
	NSImage *_image;
	NSString *_stringValue;
	NSString *_statusString;
}

@property (nonatomic, retain) NSImage *image;
@property (nonatomic, retain) NSString *stringValue;
@property (nonatomic, retain) NSString *statusString;

@end
