//
//  EXBlist.m
//  BlackFire
//
//  Created by Antwan van Houdt on 3/28/10.
//  Copyright 2010 Jabwd. All rights reserved.
//

#import "ADBitList.h"


@implementation ADBitList


- (id)init
{
	if( (self = [super init]) )
	{
		bitList = NULL;
		bitList = (unsigned char *)malloc(10);
		memset(bitList,0,10);
		size = 80;
	}
	return self;
}


/*
 * Creating the class with this method is actaully quite useless as it auto resizes.
 * But if you need raw speed it can be useful..
 */
- (id)initWithSize:(unsigned int)bitListSize
{
	if( size < 8 )
	{
		NSLog(@"EXBlist -initWithSize: ( size < 8 ) Size is too small: %u | atleast 8 or bigger.",bitListSize);
		return nil;
	}
	
	
	if( (self = [super init]) )
	{
		bitList = NULL;
		bitList = (unsigned char*)malloc(floor(bitListSize/8));
		if( bitList )
		{
			memset(bitList,0,floor(bitListSize/8));
			size = (floor(bitListSize/8)*8);
		}
		else {
			return nil;
		}
		
	}
	return self;
}

- (void)dealloc
{
	free(bitList);
	bitList = NULL;
	size = 0;
}



- (void)set:(unsigned int)index
{
	if( ! bitList || size < 8 )
		return;
	
	
	if( index > size )
		[self increaseSize:index];
	
	*(bitList + (index >> 3)) |= (1 << (index & 7));
}



- (void)unset:(unsigned int)index
{
	if( ! bitList || size < 8 )
		return;
	
	
	if( index > size )
		[self increaseSize:index];
	
	*(bitList + (index >> 3)) &= ~(1 << (index & 7));
}



- (BOOL)isSet:(unsigned int)index
{
	if( ! bitList )		return NO;
	if( size < 8 )		return NO;
	if( index > size )	return NO;
	
	
	return *(bitList + (index >> 3)) & (1 << (index & 7));
}



- (void)increaseSize:(unsigned int)index
{
	if( ! bitList || size < 8 )
		return;
	
	bitList = (unsigned char*)realloc(bitList,(index >> 3)+10);
	memset(bitList + (size >> 3),0,(index >> 3)+10-(size>>3));
	size += ((index >> 3)+10)*8;
}



/*
 * Re-sets the bitlist to 80 spots.
 */
- (void)clear
{
	if( ! bitList )
		return;
	
	
	free(bitList);
	bitList = NULL;
	bitList = (unsigned char*)malloc(10);
	memset(bitList,0,8);
	size = 80;
}
@end
