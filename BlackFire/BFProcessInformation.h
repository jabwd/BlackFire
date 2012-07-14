//
//  BFProcessInformation.h
//  BlackFire
//
//  Created by Antwan van Houdt on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFProcessInformation : NSObject

+ (NSArray *)argumentsForProcess:(int)pid;

@end
