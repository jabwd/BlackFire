//
//  BFAddGameSheetController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 12/27/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import "ADStringPromptController.h"
#import "ADApplicationDropField.h"

@class ADApplicationDropField;

@interface BFAddGameSheetController : ADStringPromptController <ADApplicationDropFieldDelegate>
{
	ADApplicationDropField *_dropField;
}

@property (nonatomic, assign) IBOutlet ADApplicationDropField *dropField;

@end
