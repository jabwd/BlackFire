//
//  BFDownload.m
//  BlackFire
//
//  Created by Antwan van Houdt on 12/10/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import "BFDownload.h"

@implementation BFDownload
{
	NSURLConnection *_connection;
	NSMutableData	*_data;
}

+ (BFDownload *)imageDownload:(NSURL *)remoteURL withDelegate:(id<BFDownloadDelegate>)delegate
{
	BFDownload *download = [[BFDownload alloc] init];
	
	NSString *path		= [remoteURL relativePath];
	NSString *fileName	= [path lastPathComponent];
	
	download.destinationPath	= [[NSString alloc] initWithFormat:@"%@/%@.image.download",NSTemporaryDirectory(),fileName];
	download.delegate			= delegate;
	
	[download downloadFromURL:remoteURL];
	
	return download;
}

+ (BFDownload *)avatarDownload:(NSURL *)remoteURL withDelegate:(id<BFDownloadDelegate>)delegate
{
	BFDownload *download = [[BFDownload alloc] init];
	
	NSString *path		= [remoteURL relativePath];
	NSString *fileName	= [path lastPathComponent];
	
	download.destinationPath	= [[NSString alloc] initWithFormat:@"%@/%@.avatar.download",NSTemporaryDirectory(),fileName];
	download.delegate			= delegate;
	
	[download downloadFromURL:remoteURL];
	
	return download;
}

- (id)init
{
	if( (self = [super init]) )
	{
		_destinationPath	= [[NSString alloc] initWithFormat:@"%@/blackfireData.bin",NSTemporaryDirectory()];
		_data				= nil;
		_connection			= nil;
		_delegate			= nil;
		_context			= nil;
	}
	return self;
}

- (void)dealloc
{
	[_connection cancel];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if( [_data length] > 0 ) 
	{
		[_data writeToFile:_destinationPath atomically:false];
		NSLog(@"%@",_destinationPath);
		NSString *string = [[NSString alloc] initWithData:_data encoding:NSASCIIStringEncoding];
		NSLog(@"%@",string);
	}
	
	if( [_delegate respondsToSelector:@selector(download:didFinishWithPath:)] )
		[_delegate download:self didFinishWithPath:_destinationPath];
	
	_destinationPath = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if( [_delegate respondsToSelector:@selector(download:didFailWithError:)] )
		[_delegate download:self didFailWithError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}



- (void)downloadFromURL:(NSURL *)remoteURL
{
	if( _connection )
		[_connection cancel];
	
	if( remoteURL )
	{		
		_data = [[NSMutableData alloc] init];
		
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL:remoteURL];
		_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		[_connection start];
	}
}


@end
