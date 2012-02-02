//
//  EXBlist.h
//  BlackFire
//
//  Created by Antwan van Houdt on 3/28/10.
//  Copyright 2010 Jabwd. All rights reserved.
//
//  ADBitList version 2.0
//

#import <Foundation/Foundation.h>


@interface ADBitList : NSObject 
{
	unsigned char *bitList;
	unsigned int   size;
}

/*
 * Turns the given index to YES
 */
- (void)set:(unsigned int)index;


/*
 * Turns the given index to NO
 */
- (void)unset:(unsigned int)index;

/*
 * Returns a boolean whether the given index
 * is set to YES or NO
 */
- (BOOL)isSet:(unsigned int)index;


/*
 * This method increases the size of the bitlist to make sure
 * that the bitlist will support the next few requests you will make
 * this increases with a few spots so it won't be called everytime you add an increasing
 * index
 */
- (void)increaseSize:(unsigned int)index;

/*
 * Re-sets the bitlist to 80 spots. You can instead of
 * calling this method just re-create the EXBlist object from scratch
 */
- (void)clear;
@end
