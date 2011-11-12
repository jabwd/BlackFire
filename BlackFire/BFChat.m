//
//  BFChat.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFChat.h"

@implementation BFChat

- (id)initWithChat:(XFChat *)chat
{
	if( (self = [super init]) )
	{
		_chat = [chat retain];
		_messages = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[_chat release];
	_chat = nil;
	[_messages release];
	_messages = nil;
	[super dealloc];
}

#pragma mark - XFChat Delegate

- (void)receivedMessage:(NSString *)message
{
	NSDictionary *newMessage = [[NSDictionary alloc] initWithObjectsAndKeys:@"",@"", nil];
	
	
	
	[newMessage release];
}

#pragma mark - Tableview datasource

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	return nil;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return 0;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	return 20.0f;
}
@end
