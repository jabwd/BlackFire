//
//  BFSoundSet.m
//  BlackFire
//
//  Created by Antwan van Houdt on 12/29/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import "BFSoundSet.h"

@implementation BFSoundSet

@synthesize name				= _name;
@synthesize path				= _path;

@synthesize sendSoundPath		= _sendSoundPath;
@synthesize receiveSoundPath	= _receiveSoundpath;
@synthesize onlineSoundPath		= _onlineSoundPath;
@synthesize offlineSoundPath	= _offlineSoundPath;
@synthesize connectedSoundPath	= _connectedSoundPath;

- (id)initWithContentsOfFile:(NSString *)path
{
	if( (self = [super init]) )
	{
		_path = [path retain];
		BOOL isDir = false;
		if( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir )
		{
			// determine what kind of bundle we are handling here.
			if( [path hasSuffix:@"AdiumSoundset"] )
			{
				[self decodeAdiumSoundSetAtPath:path];
			}
			else if( [path hasSuffix:@".BlackFireSnd"] || [path hasSuffix:@".BlackFireSoundset"] )
			{
				[self decodeBlackFireSoundSetAtPath:path];
			}
			else
			{
				NSLog(@"*** %@ Cannot decode soundset at path %@",NSStringFromClass([self class]),path);
			}
		}
		else
		{
			NSLog(@"*** %@ Cannot load soundset at path %@",NSStringFromClass([self class]),path);
		}
	}
	return self;
}

- (void)dealloc
{
	[_name release];
	_name = nil;
	[_path release];
	_path = nil;
	[_onlineSoundPath release];
	_onlineSoundPath = nil;
	[_offlineSoundPath release];
	_offlineSoundPath = nil;
	[_sendSoundPath release];
	_sendSoundPath = nil;
	[_receiveSoundpath release];
	_receiveSoundpath = nil;
	[_connectedSoundPath release];
	_connectedSoundPath = nil;
	[super dealloc];
}

#pragma mark - Decoding bundles

- (void)decodeAdiumSoundSetAtPath:(NSString *)path
{
	NSString *informationPath = [[NSString alloc] initWithFormat:@"%@/Sounds.plist",path];
	NSDictionary *information = [[NSDictionary alloc] initWithContentsOfFile:informationPath];
	
	if( information )
	{
		NSString *name = [information objectForKey:@"Info"];
		if( ! name )
			name = @"Untitled soundset";
		
		[_name release];
		_name = [name retain];
		
		
		NSDictionary *sounds = [information objectForKey:@"Sounds"];
		
		[_receiveSoundpath release];
		_receiveSoundpath = nil;
		if( [[sounds objectForKey:@"Message Received"] length] > 0 )
			_receiveSoundpath = [[NSString alloc] initWithFormat:@"%@/%@",path,[sounds objectForKey:@"Message Received"]];
		
		[_sendSoundPath release];
		_sendSoundPath = nil;
		if( [[sounds objectForKey:@"Message Sent"] length] > 0 )
			_sendSoundPath = [[NSString alloc] initWithFormat:@"%@/%@",path,[sounds objectForKey:@"Message Sent"]];
		
		[_onlineSoundPath release];
		_onlineSoundPath = nil;
		if( [[sounds objectForKey:@"Contact Signed On"] length] > 0 )
			_onlineSoundPath = [[NSString alloc] initWithFormat:@"%@/%@",path,[sounds objectForKey:@"Contact Signed On"]];
		
		[_offlineSoundPath release];
		_offlineSoundPath = nil;
		if( [[sounds objectForKey:@"Contact Signed Off"] length] > 0 )
			_offlineSoundPath = [[NSString alloc] initWithFormat:@"%@/%@",path,[sounds objectForKey:@"Contact Signed Off"]];
		
		[_connectedSoundPath release];
		_connectedSoundPath = nil;
		if( [[sounds objectForKey:@"Connected"] length] > 0 )
			_connectedSoundPath = [[NSString alloc] initWithFormat:@"%@/%@",path,[sounds objectForKey:@"Connected"]];
		else if( [[sounds objectForKey:@"Contact Signed On"] length] > 0 )
			_connectedSoundPath = [[NSString alloc] initWithFormat:@"%@/%@",path,[sounds objectForKey:@"Contact Signed On"]];
	}
	else
	{
		NSLog(@"*** Unable to decode adium sound set at path %@",path);
	}
	
	[information release];
	[informationPath release];
}

- (void)decodeBlackFireSoundSetAtPath:(NSString *)path
{
	
}

@end
