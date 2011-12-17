//
//  BFChatLog.h
//  BlackFire
//
//  Created by Antwan van Houdt on 6/12/11.
//  Copyright 2011 Exurion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFChatLog : NSObject
{
    NSString    *friendUsername;
    NSDate      *date;
}

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *friendUsername;

/*
 * Adds the messages of the array to the database
 */
- (void)addMessages:(NSMutableArray *)array;

/*
 * Gets a certain amount of messages from the database
 */
- (NSArray *)getLastMessages:(unsigned int)amount;

@end
