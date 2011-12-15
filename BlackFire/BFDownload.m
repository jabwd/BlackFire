//
//  BFDownload.m
//  BlackFire
//
//  Created by Antwan van Houdt on 12/10/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFDownload.h"

@implementation BFDownload

@synthesize destinationPath = _destinationPath;
@synthesize context			= _context;
@synthesize delegate		= _delegate;

+ (BFDownload *)imageDownload:(NSURL *)remoteURL withDelegate:(id<BFDownloadDelegate>)delegate
{
	BFDownload *download = [[BFDownload alloc] init];
	
	NSString *path		= [remoteURL relativePath];
	NSString *fileName	= [path lastPathComponent];
	
	download.destinationPath	= [[NSString alloc] initWithFormat:@"%@/%@.image.download",NSTemporaryDirectory(),fileName];
	download.delegate			= delegate;
	
	[download downloadFromURL:remoteURL];
	
	return [download autorelease];
}

+ (BFDownload *)avatarDownload:(NSURL *)remoteURL withDelegate:(id<BFDownloadDelegate>)delegate
{
	BFDownload *download = [[BFDownload alloc] init];
	
	NSString *path		= [remoteURL relativePath];
	NSString *fileName	= [path lastPathComponent];
	
	download.destinationPath	= [[NSString alloc] initWithFormat:@"%@/%@.avatar.download",NSTemporaryDirectory(),fileName];
	download.delegate			= delegate;
	
	[download downloadFromURL:remoteURL];
	
	return [download autorelease];
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
	[_context release];
	_context = nil;
	[_destinationPath release];
	_destinationPath = nil;
	[_connection cancel];
	[_connection release];
	_connection = nil;
	[_data release];
	_data		= nil;
	_delegate	= nil;
	[super dealloc];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if( [_data length] > 0 ) 
	{
		[_data writeToFile:_destinationPath atomically:false];
	}
	[_connection release];
	_connection = nil;
	[_data release];
	_data = nil;
	
	if( [_delegate respondsToSelector:@selector(download:didFinishWithPath:)] )
		[_delegate download:self didFinishWithPath:_destinationPath];
	
	[_destinationPath release];
	_destinationPath = nil;
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[_connection release];
	_connection = nil;
	[_data release];
	_data = nil;
	
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
	{
		[_connection cancel];
		[_connection release];
		_connection = nil;
	}
	if( _data )
	{
		[_data release];
		_data = nil;
	}
	
	if( remoteURL )
	{		
		_data = [[NSMutableData alloc] init];
		
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL:remoteURL];
		_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		[_connection start];
		[request release];
	}
}


@end
