//
//  XNResizingMessageView.h
//  TextFieldTest
//
//  Created by Antwan van Houdt on 2/15/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XNResizingMessageView : NSTextView
{
	NSInteger			_maxLength;
	NSSize               lastPostedSize;
	NSSize               _desiredSizeCached;
	
	BOOL				_resizing;
}

@property (assign) NSInteger maxLength;


//------------------------------------------------------------------------------------
// Auto resizing

- (NSSize)desiredSize;

@end
