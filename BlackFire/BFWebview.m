//
//  BFWebview.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/18/10.
//  Copyright 2010 Excurion. All rights reserved.
//

#import "BFWebview.h"
#import "AHHyperlinkScanner.h"
#import "AHMarkedHyperlink.h"


@implementation BFWebview

- (id)initWithFrame:(NSRect)frameRect
{
	if( (self = [super initWithFrame:frameRect]) )
	{
		// this variable prevents us from missing out on messages we received.
		// It can happen sometimes that the message is sent so quickly that the WebView 
		// has no time to load the page in time.
        [self setAutoresizingMask:63];
        webView = [[WebView alloc] initWithFrame:NSMakeRect(frameRect.origin.x, frameRect.origin.y-1, frameRect.size.width, frameRect.size.height+2) frameName:nil groupName:nil];
        [webView setAutoresizingMask:63];
        [self addSubview:webView];
		isLoaded = NO;
		messageBuffer = [[NSMutableArray alloc] init];
        [self awakeFromNib];
	}
	return self;
}

- (void)awakeFromNib
{
	[webView setFrameLoadDelegate:self];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"template" withExtension:@"html"]];
	[[webView mainFrame] loadRequest:req];
    [req release];	
	scriptObject = [webView windowScriptObject];
}

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
	if( frame == [webView mainFrame] )
	{
	if( [[[[frame provisionalDataSource] request] URL] isFileURL] && [[[[[frame provisionalDataSource] request] URL] lastPathComponent] isEqualToString:@"template.html"] )
	{
		return; // dont do anything
	}
	[[NSWorkspace sharedWorkspace] openURL:[[[frame provisionalDataSource] request] URL]];
	[sender stopLoading:self];
	}
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
	NSLog(@"*** Unable to load chat template %@",error);
	abort();
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
	if( frame == [sender mainFrame] )
	{
		isLoaded = YES;
		for(NSDictionary *message in messageBuffer)
		{
			[self newMessage:[message objectForKey:@"message"] 
					  ofType:[[message objectForKey:@"type"] boolValue]];
		}
		[messageBuffer release]; 
		messageBuffer = nil;
	}
}

- (void) dealloc
{
	scriptObject = nil; // assigned value
    [webView release];
    webView = nil;
	[messageBuffer release];
	messageBuffer = nil;
	[super dealloc];
}

- (void)close
{
    [webView close];
}

/*
 * Calls the window script object to add a new message to the webview
 * can be called from any class
 *
 * Will save a message in the messageBuffer if the webview is not yet done with loading
 */
- (void)newMessage:(NSString *)message ofType:(BOOL)type
{
	// preventing some ugly errors
	if( [message length] < 1 ) return;
	
	if( !isLoaded )
	{
		NSDictionary *messages = [[NSDictionary alloc] initWithObjectsAndKeys:message,@"message",[NSNumber numberWithBool:type],@"type", nil];
		[messageBuffer addObject:messages];
		[messages release];
		return;
	}
	message = [BFWebview filteredNSString:message];
	
	AHHyperlinkScanner *scanner = [[AHHyperlinkScanner alloc] initWithString:message usingStrictChecking:NO];
	NSArray *all = [scanner allURIs];
	// the padding because we are making the string bigger, thus the range wouldn't fit anymore
	NSUInteger padding = 0;
	for(AHMarkedHyperlink *link in all)
	{		
		NSString *linkString = [[link URL] absoluteString];
		NSString *format = [[NSString alloc] initWithFormat:@"<a href=\"%@\">%@</a>",linkString,linkString];
		NSRange linkRange = [link range];
		message = [message stringByReplacingCharactersInRange:NSMakeRange(linkRange.location+padding, linkRange.length) withString:format];
		padding = [format length] - [linkString length];
		[format release];
	}
	[scanner release];
	
	if( type )
	{
		NSArray *arg = [[NSArray alloc] initWithObjects:message,nil];
		[scriptObject callWebScriptMethod:@"insertUserMessage" withArguments:arg];
		[arg release];
	}
	else 
	{
		NSArray *arg = [[NSArray alloc] initWithObjects:message,nil];
		[scriptObject callWebScriptMethod:@"insertFriendMessage" withArguments:arg];
		[arg release];
	}
}


- (void)insertTimestamp:(NSString *)timestamp
{
	NSArray *arg = [[NSArray alloc] initWithObjects:timestamp, nil];
	[scriptObject callWebScriptMethod:@"insertTimestamp" withArguments:arg];
	[arg release];
}

- (void)newWarning:(NSString *)warning timeStamp:(NSString *)timestamp
{
	if( ! warning || [warning length] < 1 )
		return; // no empty nor NIL messages
	
	if( ! timestamp || [timestamp length] < 1 )
		return; // no nil or empty timestamp
	
	warning = [BFWebview filteredNSString:warning];
	
	AHHyperlinkScanner *scanner = [[AHHyperlinkScanner alloc] initWithString:warning usingStrictChecking:NO];
	NSArray *all = [scanner allURIs];
	
	
	// the padding because we are making the string bigger, thus the range wouldn't fit anymore
	NSUInteger padding = 0;
	for(AHMarkedHyperlink *link in all)
	{		
		NSString *linkString = [[link URL] absoluteString];
		NSString *format = [[NSString alloc] initWithFormat:@"<a href=\"%@\">%@</a>",linkString,linkString];
		NSRange linkRange = [link range];
		warning = [warning stringByReplacingCharactersInRange:NSMakeRange(linkRange.location+padding, linkRange.length) withString:format];
		padding = [format length] - [linkString length];
		[format release];
	}
	[scanner release];
	
	NSArray *arg = [[NSArray alloc] initWithObjects:timestamp,warning, nil];
	[scriptObject callWebScriptMethod:@"insertWarning" withArguments:arg];
	[arg release];
}

+ (NSString *)filteredNSString:(NSString *)p_in
{
	if( [p_in length] > 0 )
	{
		NSString *buffer = nil;
		buffer = [p_in stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
		buffer = [buffer stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
		buffer = [buffer stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
		buffer = [buffer stringByReplacingOccurrencesOfString:@"'" withString:@"&#39;"];
        buffer = [buffer stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
		return buffer;
	}
	return nil;
	
	// useless code below here, no idea why its not working properly
	
	unsigned long idx = 0,strLen = [p_in length];
	unsigned long newLen = strLen; // we need these for the new string
	unichar *buffer = (unichar*)malloc(sizeof(unichar)*strLen);
	unichar *newStr = (unichar*)malloc(sizeof(unichar)*strLen); // tmp buffer, nothing might happen
	if( ! buffer )
		return nil;
	if( ! newStr )
	{
		if( buffer )
			free(buffer);
		return nil; // can't continue
	}
	[p_in getCharacters:buffer];
	for(unsigned long i = 0;i<strLen;i++)
	{
		if( buffer[i] == '\n' )
		{
			// <br/>
			newLen += 5;
			newStr = realloc(newStr, sizeof(unichar)*(newLen));
			if( ! newStr )
				break;
			newStr[idx] = '<';
			newStr[idx+1] = 'b';
			newStr[idx+2] = 'r';
			newStr[idx+3] = '/';
			newStr[idx+4] = '>';
			idx += 5; // make sure that the index has it too.
		}
		else if( buffer[i] == '\'' )
		{
			// &#39;
			newLen += 5;
			newStr = realloc(newStr, sizeof(unichar)*(newLen));
			if( ! newStr )
				break;
			newStr[idx] = '&';
			newStr[idx+1] = '#';
			newStr[idx+2] = '3';
			newStr[idx+3] = '9';
			newStr[idx+4] = ';';
			idx += 5; // make sure that the index has it too.
		}
		else if( buffer[i] == '<' )
		{
			// &lt;
			newLen += 4;
			newStr = realloc(newStr, sizeof(unichar)*(newLen));
			if( ! newStr )
				break;
			newStr[idx]		= '&';
			newStr[idx+1]	= 'l';
			newStr[idx+2]	= 't';
			newStr[idx+3]	= ';';
			idx += 4; // make sure that the index has it too.
		}
		else if( buffer[i] == '>' )
		{
			// &gt;
			newLen += 4;
			newStr = realloc(newStr, sizeof(unichar)*(newLen));
			if( ! newStr )
				break;
			newStr[idx] = '&';
			newStr[idx+1] = 'g';
			newStr[idx+2] = 't';
			newStr[idx+3] = ';';
			idx += 4; // make sure that the index has it too.
		}
		else if( buffer[i] == '"' )
		{
			// &quot;
			newLen += 6;
			newStr = realloc(newStr, sizeof(unichar)*(newLen));
			if( ! newStr )
				break;
			newStr[idx] = '&';
			newStr[idx+1] = 'q';
			newStr[idx+2] = 'u';
			newStr[idx+3] = 'o';
			newStr[idx+4] = 't';
			newStr[idx+5] = ';';
			idx += 6; // make sure that the index has it too.
		}
		else
		{
			newStr[idx] = buffer[i];
			idx++;
		}
	}
	if( buffer )
		free(buffer);
	
	
	//NSString *newst = [[NSString alloc] initWithCharacters:newStr length:newLen];
	NSString *newst = [[NSString alloc] initWithBytes:newStr length:newLen encoding:NSUTF8StringEncoding];
	
	if( newStr )
		free(newStr);
	
	return [newst autorelease];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor whiteColor] set];
    NSRectFill(dirtyRect);
	
	[[NSColor grayColor] set];
	NSRectFill(NSMakeRect(dirtyRect.origin.x, dirtyRect.size.height-1, dirtyRect.size.width, 1));
}

- (void)scrollDown
{
	[scriptObject callWebScriptMethod:@"scrollToBottom" withArguments:nil];
}
@end
