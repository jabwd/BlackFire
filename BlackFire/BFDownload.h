//
//  BFDownload.h
//  BlackFire
//
//  Created by Antwan van Houdt on 12/10/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BFDownload;

@protocol BFDownloadDelegate <NSObject>
- (void)download:(BFDownload *)download didFailWithError:(NSError *)error;
- (void)download:(BFDownload *)download didFinishWithPath:(NSString *)path;
@end

@interface BFDownload : NSObject

@property (unsafe_unretained) id <BFDownloadDelegate> delegate;
@property (nonatomic, strong) id context;

@property (nonatomic, strong) NSString *destinationPath;

+ (BFDownload *)imageDownload:(NSURL *)remoteURL withDelegate:(id<BFDownloadDelegate>)delegate;
+ (BFDownload *)avatarDownload:(NSURL *)remoteURL withDelegate:(id<BFDownloadDelegate>)delegate;

- (void)downloadFromURL:(NSURL *)remoteURL;

@end
