//
//  BFMessageCell.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van houdt. All rights reserved.
//



@interface BFMessageCell : NSTextFieldCell
{
	NSString *_displayName;
	NSDate	 *_date;
}

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSDate *date;

@end
