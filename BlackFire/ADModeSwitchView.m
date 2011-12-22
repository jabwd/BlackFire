//
//  ADModeSwitchView.m
//  TestApp
//
//  Created by Antwan van Houdt on 12/20/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import "ADModeSwitchView.h"
#import "ADModeItem.h"

@implementation ADModeSwitchView

@synthesize selector = _selector;
@synthesize target = _target;

- (id)initWithFrame:(NSRect)frame
{
    if( (self = [super initWithFrame:frame]) )
	{
		_items = [[NSMutableArray alloc] init];
		
		ADModeItem *item = [[ADModeItem alloc] init];
		item.name = @"Friends";
		item.selected = true;
		[_items addObject:item];
		[item release];
		
		item = [[ADModeItem alloc] init];
		item.name = @"Games";
		[_items addObject:item];
		[item release];
		
		item = [[ADModeItem alloc] init];
		item.name = @"Servers";
		[_items addObject:item];
		[item release];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:NSWindowDidBecomeMainNotification object:self.window];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:NSWindowDidResignMainNotification object:self.window];
	}
    return self;
}

- (void)dealloc
{
	[_items release];
	_items = nil;
	[super dealloc];
}

- (void)update
{
	[self setNeedsDisplay:true];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint mouseLocation	= [NSEvent mouseLocation];
	
	NSPoint new = [[self window] convertScreenToBase:mouseLocation];
	NSPoint actual = [self convertPoint:new fromView:[[[self window] contentView] superview]];
	
	CGFloat totalSize = 5.0f;
	for(ADModeItem *item in _items)
	{
		totalSize += [item size].width + 10;
	}
	totalSize -= 10;
	
	// now calculate the starting position, totalSize will be the starting X
	CGFloat endSize = totalSize;
	NSRect dirtyRect = [self frame];
	totalSize = (dirtyRect.size.width-totalSize)/2;
	endSize += totalSize; // this is the actual end size
	//endSize -= 10;
	if( actual.x > totalSize && actual.x < endSize )
	{
		actual.x -= totalSize;
		if( actual.x > ([[_items objectAtIndex:0] size].width+5) )
		{
			if( actual.x > ([[_items objectAtIndex:0] size].width+5+[[_items objectAtIndex:1] size].width+10) )
			{
				// third
				[self selectItemAtIndex:2];
			}
			else
			{
				// second
				[self selectItemAtIndex:1];
			}
		}
		else
		{
			[self selectItemAtIndex:0];
		}
	}
	
	[_target performSelector:_selector withObject:self];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return true;
}

- (void)selectItemAtIndex:(NSUInteger)index
{
	for(ADModeItem *item in _items)
	{
		if( item.selected )
			item.selected = false;
	}
	
	[[_items objectAtIndex:index] setSelected:true];
	[self setNeedsDisplay:true];
}

- (NSInteger)selectedItemIndex
{
	NSInteger i, cnt = [_items count];
	for(i=0;i<cnt;i++)
	{
		ADModeItem *item = [_items objectAtIndex:i];
		if( item.selected )
			return i;
	}
	return 0;
}


- (void)drawRect:(NSRect)dirtyRect
{	
	NSGradient	*gradient	= nil;
	if( [self.window isMainWindow] )
	{
		gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:.7377 alpha:1.0f] endingColor:[NSColor colorWithCalibratedWhite:0.8588 alpha:1.0f]];
		[gradient drawInRect:dirtyRect angle:90.0f];
		[gradient release];
		[[NSColor colorWithCalibratedWhite:0.4f alpha:1.0f] set];
		NSRectFill(NSMakeRect(0, dirtyRect.origin.y, dirtyRect.size.width+1, 1));
		
	}
	else
	{
		gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:.85 alpha:1.0f] endingColor:[NSColor colorWithCalibratedWhite:0.96 alpha:1.0f]];
		[gradient drawInRect:dirtyRect angle:90.0f];
		[gradient release];
		[[NSColor colorWithCalibratedWhite:0.65f alpha:1.0f] set];
		NSRectFill(NSMakeRect(0, dirtyRect.origin.y, dirtyRect.size.width+1, 1));
	}
	
	
	CGFloat totalSize  = 0.0f; // 16.886230f
	for(ADModeItem *item in _items)
	{
		totalSize += [item size].width;
	}
	
	totalSize += 15; // fix the centering.
	
	// now calculate the starting position
	totalSize = (dirtyRect.size.width-totalSize)/2;
	
	NSUInteger i, cnt = [_items count];
	for(i=0;i<cnt;i++)
	{
		ADModeItem *item = [_items objectAtIndex:i];
		
		NSShadow *shadow = [[NSShadow alloc] init];
		if( item.selected )
		{
			
			if( [self.window isMainWindow] )
				[shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.2 alpha:1.0f]];
			else
				[shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.4 alpha:1.0f]];
			[shadow setShadowOffset:NSMakeSize(0, -1)];
			[shadow setShadowBlurRadius:2.5f];
			
		}
		else
		{
			[shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
			[shadow setShadowColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:0.41]];
		}
		
		NSColor *textColor = nil;
		
		if( [self.window isMainWindow] )
		{
			if( item.selected )
				textColor = [NSColor whiteColor];
			else
				textColor = [NSColor controlTextColor];
			
			//textColor = [NSColor controlTextColor];
		}
		else
		{
			if( item.selected )
				textColor = [NSColor colorWithCalibratedWhite:0.9 alpha:1.0f];
			else
				textColor = [NSColor disabledControlTextColor];
			
			//textColor = [NSColor disabledControlTextColor];
		}
		
		NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont systemFontOfSize:([NSFont systemFontSize])],NSFontAttributeName, shadow,NSShadowAttributeName, textColor,NSForegroundColorAttributeName, nil];
		
		NSAttributedString *str = [[NSAttributedString alloc] initWithString:item.name attributes:attributes];
		[attributes release];
		
		NSSize size = [str size];
		
		if( item.selected )
		{
			/*[[NSGraphicsContext currentContext] setShouldAntialias:false];
			NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(totalSize-6, (dirtyRect.size.height/2 - size.height/2)-2, size.width+10, size.height+4) xRadius:2.0f yRadius:2.0f];
			if( [self.window isMainWindow] )
				[[NSColor colorWithCalibratedWhite:0.4 alpha:1.0f] set];
			else
				[[NSColor colorWithCalibratedWhite:0.65 alpha:1.0f] set];
			[path fill];
			[[NSGraphicsContext currentContext] setShouldAntialias:true];*/
			
			if( [self.window isMainWindow] )
				[[NSColor colorWithCalibratedWhite:0.4 alpha:1.0f] set];
			else
				[[NSColor colorWithCalibratedWhite:0.65 alpha:1.0f] set];
			NSRectFill(NSMakeRect(totalSize-6, 0, size.width+10, dirtyRect.size.height));
			
			/*NSImage *left = [NSImage imageNamed:@"selection_left"];
			NSImage *right = [NSImage imageNamed:@"selection_right"];
			
			[left drawInRect:NSMakeRect(totalSize-6, 3, 3, dirtyRect.size.height-2) fromRect:NSMakeRect(0, 0, 3, dirtyRect.size.height-1) operation:NSCompositeSourceOver fraction:1.0f];
			[right drawInRect:NSMakeRect(totalSize+size.width+3, 3, 3, dirtyRect.size.height-2) fromRect:NSMakeRect(0, 0, 3, dirtyRect.size.height-1) operation:NSCompositeSourceOver fraction:1.0f];*/
		}
		
		[str drawInRect:NSMakeRect(totalSize, (dirtyRect.size.height/2 - size.height/2)+2, size.width, size.height-1)];
		[str release];
		
		totalSize += size.width + 10;
	}
}
		 
		 
/*- (void)drawImage:(NSImage *)image etchedInRect:(NSRect)rect
{
	NSSize size = rect.size;
	CGFloat dropShadowOffsetY = size.width <= 64.0 ? -1.0 : -2.0;
	CGFloat innerShadowBlurRadius = size.width <= 32.0 ? 1.0 : 4.0;
	
	CGContextRef c = [[NSGraphicsContext currentContext] graphicsPort];
	
	//save the current graphics state
	CGContextSaveGState(c);
	
	//Create mask image:
	NSRect maskRect = rect;
	CGImageRef maskImage = [image CGImageForProposedRect:&maskRect context:[NSGraphicsContext currentContext] hints:nil];
	
	//Draw image and white drop shadow:
	CGContextSetShadowWithColor(c, CGSizeMake(0, dropShadowOffsetY), 0, CGColorGetConstantColor(kCGColorWhite));
	[image drawInRect:maskRect fromRect:NSMakeRect(0, 0, image.size.width, image.size.height) operation:NSCompositeSourceOver fraction:1.0];
	
	//Clip drawing to mask:
	CGContextClipToMask(c, NSRectToCGRect(maskRect), maskImage);
	
	//Draw gradient:
	NSGradient *gradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:0.5 alpha:1.0]
														  endingColor:[NSColor colorWithDeviceWhite:0.25 alpha:1.0]] autorelease];
	[gradient drawInRect:maskRect angle:90.0];
	CGContextSetShadowWithColor(c, CGSizeMake(0, -1), innerShadowBlurRadius, CGColorGetConstantColor(kCGColorBlack));
	
	//Draw inner shadow with inverted mask:
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef maskContext = CGBitmapContextCreate(NULL, CGImageGetWidth(maskImage), CGImageGetHeight(maskImage), 8, CGImageGetWidth(maskImage) * 4, colorSpace, kCGImageAlphaPremultipliedLast);
	CGColorSpaceRelease(colorSpace);
	CGContextSetBlendMode(maskContext, kCGBlendModeXOR);
	CGContextDrawImage(maskContext, maskRect, maskImage);
	CGContextSetRGBFillColor(maskContext, 1.0, 1.0, 1.0, 1.0);
	CGContextFillRect(maskContext, maskRect);
	CGImageRef invertedMaskImage = CGBitmapContextCreateImage(maskContext);
	CGContextDrawImage(c, maskRect, invertedMaskImage);
	CGImageRelease(invertedMaskImage);
	CGContextRelease(maskContext);
	
	//restore the graphics state
	CGContextRestoreGState(c);
}*/


@end
