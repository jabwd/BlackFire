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
@synthesize receiveSoundPath	= _receiveSoundPath;
@synthesize onlineSoundPath		= _onlineSoundPath;
@synthesize offlineSoundPath	= _offlineSoundPath;
@synthesize connectedSoundPath	= _connectedSoundPath;

@synthesize valid				= _valid;

- (id)initWithContentsOfFile:(NSString *)path
{
	if( (self = [super init]) )
	{
		_path = [path retain];
		BOOL isDir = false;
		if( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir )
		{
			// determine what kind of bundle we are handling here.
			if( [path hasSuffix:@"AdiumSoundset"] || [path hasSuffix:@"AdiumSoundSet"] )
			{
				[self decodeAdiumSoundSetAtPath:path];
			}
			else if( [path hasSuffix:@".BlackFireSnd"] || [path hasSuffix:@".BlackFireSoundset"] || [path hasSuffix:@".BlackFireSoundSet"] )
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
	[_receiveSoundPath release];
	_receiveSoundPath = nil;
	[_connectedSoundPath release];
	_connectedSoundPath = nil;
	[super dealloc];
}

#pragma mark - Decoding bundles

- (void)decodeAdiumSoundSetAtPath:(NSString *)path
{
	NSString *informationPath = [[NSString alloc] initWithFormat:@"%@/Sounds.plist",path];
	NSDictionary *information = [[NSDictionary alloc] initWithContentsOfFile:informationPath];
	
	if( ! information )
	{
		//NSLog(@"Notice: no info property list found in the adium soundset, probably some retard who thinks using a plain text file is handier");
		// scan the plain text file, *sigh*
		// oh, another bonus from these retards, the file can have a random name :D
		NSError *error = nil;
		NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
		if( ! error )
		{
			NSString *filePath = nil;
			for(NSString *fileName in directoryContents)
			{
				if( [fileName rangeOfString:@".txt"].length > 0 )
				{
					filePath = [NSString stringWithFormat:@"%@/%@",path,fileName];
					break;
				}
			}
			
			if( ! filePath )
			{
				[informationPath release];
				return;
			}
			else
			{
				NSString *contents = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
				if( error )
				{
					NSLog(@"*** Unable to decode adium soundset");
					[contents release];
					[informationPath release];
					return;
				}
				else
				{
					// scan the file for the information we need
					NSArray *components = [contents componentsSeparatedByString:@"\n"];
					BOOL useful = false;
					information = (NSDictionary *)[[NSMutableDictionary alloc] init];
					if( [components count] > 0 )
					{
						NSString *name = components[0];
						((NSMutableDictionary *)information)[@"Info"] = name;
					}
					else
					{
						[informationPath release];
						[information release];
						[contents release];
						return;
					}
					for(NSString *line in components)
					{
						if( ! useful )
						{
							if( [line length] > 8 )
							{
								if( [line rangeOfString:@"SoundSet:"].length == 9 )
								{
									useful = true;
								}
							}
						}
						else
						{
							NSString *key	= nil;
							NSString *value = nil;
							NSArray *comp = [line componentsSeparatedByString:@"\""];
							if( [comp count] > 2 )
							{
								key		= comp[1];
								value	= comp[2];
								
								// finish the value
								NSRange valueRange = [value rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
								valueRange.length = [value length] - valueRange.location;
								value = [value substringWithRange:valueRange];
							}
							if( key && value )
							{
								((NSMutableDictionary *)information)[key] = value;
							}
						}
					}
				}
				[contents release];
			}
		}
		else
		{
			[informationPath release];
			return;
		}
	}
	
	if( information )
	{
		/*NSString *name = [information objectForKey:@"Info"];
		if( ! name )
			name = @"Untitled soundset";*/
		
		//[_name release];
		//_name = [name retain];
		[_name release];
		NSString *soundsetFile = [_path lastPathComponent];
		NSArray *comp = [soundsetFile componentsSeparatedByString:@"."];
		if( [comp count] > 0 )
		{
			_name = [comp[0] retain];
		}
		
		if( ! _name )
			_name = [@"Untitled" retain];
		
		
		NSDictionary *sounds = information[@"Sounds"];
		if( ! sounds )
			sounds = information;
		
		[_receiveSoundPath release];
		_receiveSoundPath = nil;
		if( [sounds[@"Message Received"] length] > 0 )
			_receiveSoundPath = [[NSString alloc] initWithFormat:@"%@/%@",path,sounds[@"Message Received"]];
		
		[_sendSoundPath release];
		_sendSoundPath = nil;
		if( [sounds[@"Message Sent"] length] > 0 )
			_sendSoundPath = [[NSString alloc] initWithFormat:@"%@/%@",path,sounds[@"Message Sent"]];
		
		[_onlineSoundPath release];
		_onlineSoundPath = nil;
		if( [sounds[@"Contact Signed On"] length] > 0 )
			_onlineSoundPath = [[NSString alloc] initWithFormat:@"%@/%@",path,sounds[@"Contact Signed On"]];
		
		[_offlineSoundPath release];
		_offlineSoundPath = nil;
		if( [sounds[@"Contact Signed Off"] length] > 0 )
			_offlineSoundPath = [[NSString alloc] initWithFormat:@"%@/%@",path,sounds[@"Contact Signed Off"]];
		
		[_connectedSoundPath release];
		_connectedSoundPath = nil;
		if( [sounds[@"Connected"] length] > 0 )
			_connectedSoundPath = [[NSString alloc] initWithFormat:@"%@/%@",path,sounds[@"Connected"]];
		else if( [sounds[@"Contact Signed On"] length] > 0 )
			_connectedSoundPath = [[NSString alloc] initWithFormat:@"%@/%@",path,sounds[@"Contact Signed On"]];
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
	NSString *informationPath = [[NSString alloc] initWithFormat:@"%@/Info.plist",path];
	NSDictionary *information = [[NSDictionary alloc] initWithContentsOfFile:informationPath];
	
	if( information )
	{
		NSString *name = information[@"soundsetName"];
		if( ! name )
			name = @"Untitled soundset";
		
		[_name release];
		_name = [name retain];
		
		
		[_receiveSoundPath release];
		_receiveSoundPath = nil;
		if( [information[@"receiveSound"] length] > 0 )
			_receiveSoundPath = [[NSString alloc] initWithFormat:@"%@/%@",path,information[@"receiveSound"]];
		
		[_sendSoundPath release];
		_sendSoundPath = nil;
		if( [information[@"sendSound"] length] > 0 )
			_sendSoundPath = [[NSString alloc] initWithFormat:@"%@/%@",path,information[@"sendSound"]];
		
		[_onlineSoundPath release];
		_onlineSoundPath = nil;
		if( [information[@"onlineSound"] length] > 0 )
			_onlineSoundPath = [[NSString alloc] initWithFormat:@"%@/%@",path,information[@"onlineSound"]];
		
		[_offlineSoundPath release];
		_offlineSoundPath = nil;
		if( [information[@"offlineSound"] length] > 0 )
			_offlineSoundPath = [[NSString alloc] initWithFormat:@"%@/%@",path,information[@"offlineSound"]];
		
		[_connectedSoundPath release];
		_connectedSoundPath = nil;
		if( [information[@"connectedSound"] length] > 0 )
			_connectedSoundPath = [[NSString alloc] initWithFormat:@"%@/%@",path,information[@"connectedSound"]];
		else if( [information[@"onlineSound"] length] > 0 )
			_connectedSoundPath = [[NSString alloc] initWithFormat:@"%@/%@",path,information[@"onlineSound"]];

	}
	
	[informationPath release];
	[information release];
}

@end
