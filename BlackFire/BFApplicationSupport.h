//
//  BFApplicationSupport.h
//  BlackFire
//
//  Created by Antwan van Houdt on 12/28/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import <Foundation/Foundation.h>

BOOL createFolderIfNeeded(NSString *path);

static inline NSString *BFApplicationSupportPath()
{
	return [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
}

static inline NSString *BFChatLogDirectoryPath()
{
	NSString *path = [NSString stringWithFormat:@"%@/BlackFire/ChatLogs",BFApplicationSupportPath()];
	if( ! createFolderIfNeeded(path) )
		return nil;
	return path;
}

static inline NSString *BFSoundsetsDirectoryPath()
{
	NSString *path = [NSString stringWithFormat:@"%@/BlackFire/SoundSets",BFApplicationSupportPath()];
	if( ! createFolderIfNeeded(path) )
		return nil;
	return path;
}

static inline NSString *BFExtraMacGameSupportFilePath()
{
	NSString *path = BFApplicationSupportPath();
	if( ! createFolderIfNeeded(path) )
		return nil;
	return [NSString stringWithFormat:@"%@/BlackFire/MacGameAdditions.plist",path];
}
