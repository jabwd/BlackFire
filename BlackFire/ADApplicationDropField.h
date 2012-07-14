//
//  ADApplicationDropField.h
//  BlackFire
//
//  Created by Antwan van Houdt on 12/27/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ADApplicationDropFieldDelegate <NSObject>
- (void)applicationPathChanged:(NSString *)newPath;
@end

@interface ADApplicationDropField : NSView

@property (nonatomic, unsafe_unretained) id <ADApplicationDropFieldDelegate> delegate;
@property (nonatomic, strong) NSString *applicationPath;



@end
