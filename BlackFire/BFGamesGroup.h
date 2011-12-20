//
//  BFGamesGroup.h
//  BlackFire
//
//  Created by Antwan van Houdt on 6/21/11.
//  Copyright 2011 Exurion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFGamesGroup : NSObject
{
    NSMutableArray	*members;
    NSString		*name;
}
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *members;

@end
