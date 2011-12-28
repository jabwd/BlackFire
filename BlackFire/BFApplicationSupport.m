//
//  BFApplicationSupport.m
//  BlackFire
//
//  Created by Antwan van Houdt on 12/28/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import "BFApplicationSupport.h"

BOOL createFolderIfNeeded(NSString *path)
{
	BOOL isDir = false;
	if( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir )
	{
		return true;
	}
	else
	{
		NSError *error = nil;
		[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:true attributes:nil error:&error];
		if( error )
		{
			NSLog(@"*** Error while creating %@ %@",path,error);
			return false;
		}
	}
	return true;
}
