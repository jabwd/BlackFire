//
//  ADMessageCell.h
//  BubbleTest
//
//  Created by Antwan van Houdt on 11/30/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADMessageCell : NSTextFieldCell
{
	BOOL _type;
}

@property (assign) BOOL type;

@end
