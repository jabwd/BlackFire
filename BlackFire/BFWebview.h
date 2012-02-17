//
//  BFWebview.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/18/10.
//  Copyright 2010 Excurion. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


@interface BFWebview : NSView
{
	IBOutlet WebView *webView;
	WebScriptObject *scriptObject;
	
	
	/*
	 * The following instance variables are used to make sure the webview is 
	 * loaded before the messages are processed.
	 */
	BOOL isLoaded;
	NSMutableArray *messageBuffer;
}
- (void)newMessage:(NSString *)message timeStamp:(NSString *)timestamp withNickName:(NSString *)nickName ofType:(BOOL)type;
- (void)newWarning:(NSString *)warning timeStamp:(NSString *)timestamp;

+ (NSString *)filteredNSString:(NSString *)p_in;
- (void)close;
@end
