//
//  BFIdleTimeManager.h
//  BlackFire
//
//  Created by Mark Douma on 1/31/2010.
//  Copyright 2010 Mark Douma LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <ApplicationServices/ApplicationServices.h>

@protocol BFIdleTimeManagerDelegate <NSObject>
- (void)userWentAway;
- (void)userBecameActive;
@end

@interface BFIdleTimeManager : NSObject 
{
	NSTimer				*timer;
	CGEventSourceRef	eventSourceRef;
    id <BFIdleTimeManagerDelegate>	_delegate;
	
	BOOL              isIdle;
	BOOL              setAwayStatusAutomatically;

}

@property (assign) id <BFIdleTimeManagerDelegate> delegate;

+ (BFIdleTimeManager *)defaultManager;
- (void)setSetAwayStatusAutomatically:(BOOL)shouldSetAutomatically;

@end
