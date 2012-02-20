//
//  ADMessage.h
//  BubbleTest
//
//  Created by Antwan van Houdt on 2/18/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADMessage : NSObject
{
	NSDate *_timestamp;
	NSString *_message;
	BOOL _type;
}

@property (nonatomic,retain) NSDate *timestamp;
@property (nonatomic, retain) NSString *message;
@property (assign) BOOL type;


@end
