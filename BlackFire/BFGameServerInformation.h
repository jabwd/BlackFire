//
//  BFGameServerInformation.h
//  BlackFire
//
//  Created by Antwan van Houdt on 6/10/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskWrapper.h"

@class XFGameServer, XFFriend;

@protocol BFGameServerInformationDelegate <NSObject>
- (void)receivedInformationForServer:(XFGameServer *)server;
@end

@interface BFGameServerInformation : NSObject <TaskWrapperController>

@property (nonatomic, unsafe_unretained) id <BFGameServerInformationDelegate> delegate;

+ (id)sharedInformation;

- (void)getInformationForFriend:(XFFriend *)friend;

- (void)nextTask;

- (void)getServerInfoWithIP:(NSString *)ip andGameName:(NSString *)gameName;

@end
