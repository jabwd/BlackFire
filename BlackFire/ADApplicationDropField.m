//
//  ADApplicationDropField.m
//  BlackFire
//
//  Created by Antwan van Houdt on 12/27/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import "ADApplicationDropField.h"

@implementation ADApplicationDropField

@synthesize delegate = _delegate;
@synthesize applicationPath = _applicationPath;

- (void)dealloc
{
	_delegate = nil;
	[_applicationPath release];
	_applicationPath = nil;
	[super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSImage *image = [NSImage imageNamed:@"game_here"];
	[image drawInRect:dirtyRect fromRect:NSMakeRect(0, 0, dirtyRect.size.width, dirtyRect.size.height) operation:NSCompositeSourceOver fraction:1.0f];
}

- (void)awakeFromNib
{
	[self registerForDraggedTypes:@[NSFilenamesPboardType]];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender 
{
    NSPasteboard *pboard;
    //NSDragOperation sourceDragMask;
	
    //sourceDragMask	= [sender draggingSourceOperationMask];
    pboard			= [sender draggingPasteboard];
	
    if( [[pboard types] containsObject:NSFilenamesPboardType] ) 
	{
		NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		if( [files count] > 1 )
		{
			return NSDragOperationNone;
		}
		
		NSString *file = files[0];
		BOOL isDirectory = false;
		if( [[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDirectory] && isDirectory )
		{
			if( [file hasSuffix:@".app"] )
			{
				return NSDragOperationCopy;
			}
		}
	}
	
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender 
{
	NSPasteboard *pboard;
    //NSDragOperation sourceDragMask;
	
    //sourceDragMask	= [sender draggingSourceOperationMask];
    pboard			= [sender draggingPasteboard];
	
    if( [[pboard types] containsObject:NSFilenamesPboardType] ) 
	{
		NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		if( [files count] > 1 )
		{
			return NSDragOperationNone;
		}
		
		NSString *file = files[0];
		BOOL isDirectory = false;
		if( [[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDirectory] && isDirectory )
		{
			if( [file hasSuffix:@".app"] )
			{
				[_applicationPath release];
				_applicationPath = [file retain];
				if( [_delegate respondsToSelector:@selector(applicationPathChanged:)] )
					[_delegate applicationPathChanged:_applicationPath];
			}
		}
	}
    return YES;
}

@end
