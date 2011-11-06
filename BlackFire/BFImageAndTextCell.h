//
//  BFLoginViewController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 5/7/2011.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//


#import <Cocoa/Cocoa.h>

typedef enum
{
	CellStatusOnline	= 1,
	CellStatusAFK		= 2,
	CellStatusOffline	= 3
} CellStatus;

@interface BFImageAndTextCell : NSTextFieldCell
{
	NSImage *_image;
	NSImage *_statusImage;
	NSSize _displayImageSize;
    NSAttributedString *statusString;
    BOOL showsStatus;
    BOOL wasHighlighted;
	
	CellStatus status;
}

@property (nonatomic, retain) NSImage *image;
@property (nonatomic, assign) CellStatus status;
@property (nonatomic, retain) NSImage *statusImage;


- (void)setImage:(NSImage *)anImage;
- (NSImage *)image;

- (NSAttributedString *)statusString;
- (void)setCellStatusString:(NSString *)aString;
- (void)setShowsStatus:(BOOL)aBool;
- (BOOL)showsStatus;
- (void)setFriendStatus:(CellStatus)newStatus;

- (void)setDisplayImageSize:(NSSize)sz;
- (NSSize)displayImageSize;

@end