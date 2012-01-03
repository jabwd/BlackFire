//
//  BFSoundSet.h
//  BlackFire
//
//  Created by Antwan van Houdt on 12/29/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFSoundSet : NSObject

@property (readonly) NSString *name;
@property (readonly) NSString *path;

@property (readonly) NSString *sendSoundPath;
@property (readonly) NSString *receiveSoundPath;
@property (readonly) NSString *onlineSoundPath;
@property (readonly) NSString *offlineSoundPath;
@property (readonly) NSString *connectedSoundPath;

@property (readonly) BOOL valid;


- (id)initWithContentsOfFile:(NSString *)path;


#pragma mark - Decoding soundsets


- (void)decodeAdiumSoundSetAtPath:(NSString *)path;
- (void)decodeBlackFireSoundSetAtPath:(NSString *)path;

@end
