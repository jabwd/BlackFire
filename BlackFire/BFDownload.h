//
//  BFDownload.h
//  BlackFire
//
//  Created by Antwan van Houdt on 12/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BFDownload;

@protocol BFDownloadDelegate <NSObject>
- (void)download:(BFDownload *)download didFailWithError:(NSError *)error;
- (void)download:(BFDownload *)download didFinishWithPath:(NSString *)path;
@end

@interface BFDownload : NSObject <NSURLConnectionDelegate>
{
	NSURLConnection *_connection;
	NSMutableData	*_data;
	
	NSString *_destinationPath;
	
	id <BFDownloadDelegate> _delegate;
}

@property (assign) id <BFDownloadDelegate> delegate;

@property (nonatomic, retain) NSString *destinationPath;

+ (BFDownload *)imageDownload:(NSURL *)remoteURL withDelegate:(id<BFDownloadDelegate>)delegate;

- (void)downloadFromURL:(NSURL *)remoteURL;

@end
